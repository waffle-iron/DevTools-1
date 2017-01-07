using namespace System.Management.Automation
using namespace System.Collections.ObjectModel

using module .\Src\Types.psm1
using module .\Src\DynamicParameter.psm1
using module .\Src\DynamicConfig.psm1

$global:devTools = New-Object DynamicConfig

function Use-DevTools
{
    [CmdletBinding()]
    param
    (
        [Switch]$NoPublish,
        [Switch]$WhatIf,
        [Parameter(ValueFromRemainingArguments = $true)]
        $CustomVersion = $false,
        [Parameter(ValueFromRemainingArguments = $true)]
        $GenerateProject = $false
    )
    
    DynamicParam
    {
        $devTools.whatIf = $whatIf.IsPresent
        $devTools.setEnvironment()
        return $devTools.dynamicParameters([ref]$psBoundParameters)
    }
    process
    {
        [String]$project = $psBoundParameters['Project']
        [Action]$action = $psBoundParameters['Action']
        [VersionComponent]$versionType = $psBoundParameters['VersionType']
        
        if ($generateProject)
        {
            ($devTools.moduleFactory($generateProject)).create()
            return
        }
        
        $provision = $devTools.provisionFactory($project)
        $version = $devTools.versionFactory()
        
        $cpu_architecture = switch ([Boolean]$env:PLATFORM)
        {
            true { $env:PLATFORM }
            false { $env:PROCESSOR_ARCHITECTURE }
        }
        
        $info = '{0} {1} {2} [{3} {4}]' -f $project, $version.version, `
        $action, $cpu_architecture, $env:COMPUTERNAME
        
        $devTools.info($devTools.cr + $info + $devTools.cr)
        
        $nextVersion = switch ([Boolean]$customVersion)
        {
            True { $customVersion }
            Default { $version.next($versionType) }
        }
        
        switch ($action)
        {
            ([Action]::Cleanup) { $provision.cleanup() }
            ([Action]::Install) { $provision.install() }
            ([Action]::CopyToCurrentUserModules) { $provision.copy() }
            ([Action]::BumpVersion) { $provision.bumpVersion($version, $nextVersion) }
            ([Action]::Publish) { $provision.publish() }
            ([Action]::Deploy)
            {
                $provision.bumpVersion($version, $nextVersion)
                $provision.publish()
            }
            ([Action]::Build)
            {
                if ($env:APPVEYOR_REPO_TAG -eq $false)
                {
                    $devTools.warning('Task [Build] is not allowed on {0}!' -f $env:APPVEYOR_REPO_BRANCH)
                    break
                }
                $devTools.appVeyor.pushArtifact($provision, $version.version)
            }
            ([Action]::Release)
            {
                while ($choice -notmatch '[y|n]')
                {
                    Read-Host -OutVariable choice `
                              -Prompt "Publish The Next [$nextVersion] Release, Are You Shure?(Y/N)"
                }
                
                if ($choice -eq 'n') { break }
                
                $provision.bumpVersion($version, $nextVersion)
                $provision.gitCommitVersionChange($nextVersion)
                $provision.gitTag($nextVersion)
                
                if ($noPublish.isPresent) { break }
                
                $provision.publish()
            }
            ([Action]::Test)
            {
                if ($env:APPVEYOR_REPO_TAG -eq $true)
                {
                    $devTools.warning('Task [Test] is not allowed on Tag branches!')
                    return
                }
                
                Invoke-Expression $provision.entryPoint
            }
            default { }
        }
    }
}

New-Alias -Name dt -Value Use-DevTools

Register-ArgumentCompleter -CommandName dt -ScriptBlock {
    param (
        $wordToComplete,
        $commandAst,
        $cursorPosition
    )
    
    $ast = (-split $commandAst)
    $count = $ast.length
    $last = $ast[- $true]
    
    $methods = [Enum]::GetValues([Action])
    
    if (($devTools.isInProject -and $count -eq 2) -or (!$devTools.isInProject -and $count -eq 1))
    {
        $methods = $devTools.getProjects()
    }
    
    if ($count -eq 3) { $methods = [Enum]::GetValues([VersionComponent]) }
    
    $matches = $methods | Where-Object { $_ -like "*$wordToComplete*" }
    
    $matches = switch ([Boolean]$matches.Count) { True { $matches } False { $methods } }
    
    $matches | Sort-Object | ForEach-Object { [CompletionResult]::new($_) }
}
