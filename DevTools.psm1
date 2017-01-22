using namespace System.Management.Automation

using module .\Src\Enums.psm1
using module .\Src\DynamicConfig.psm1

using module .\Src\Manager\AppVeyorManager.psm1
using module .\Src\Manager\ModuleManager.psm1
using module .\Src\Manager\ProvisionManager.psm1
using module .\Src\Manager\VersionManager.psm1


Set-StrictMode -Version latest

[DynamicConfig]$script:devTools = $null

function Use-DevTools
{
    [CmdletBinding()]
    param
    (
        [Switch]$WhatIf,
        [Switch]$NoPublish,
        [Switch]$GenerateProject,
        [Parameter(ValueFromRemainingArguments = $true)]
        $CustomVersion = $false
    )
    
    DynamicParam
    {
        $script:devTools = $devTools = New-Object DynamicConfig
        
        $devTools.setEnvironment()
        
        return $devTools.dynamicParameters([ref]$psBoundParameters)
    }
    process
    {
        $devTools.setProjectVariables($psBoundParameters)
        
        if ($generateProject)
        {
            #([ModuleManager]$devTools.moduleFactory()).create()
            return
        }
        
        
        [AppVeyorManager]$appVeyor = $devTools.appVeyorFactory()
        [ProvisionManager]$provision = $devTools.provisionFactory()
        [VersionManager]$version = $devTools.versionFactory()
        

        
        
        $cpu_architecture = switch ([Boolean]$env:PLATFORM)
        {
            true { $env:PLATFORM }
            false { $env:PROCESSOR_ARCHITECTURE }
        }
        
        $info = '{5}{0} {1} {2} [{3} {4}]{5}' -f $devTools.projectName, $version.version, `
        $devTools.action, $cpu_architecture, $env:COMPUTERNAME, [Environment]::NewLine
        
        $devTools.info($info)
        
        $nextVersion = switch ([Boolean]$customVersion)
        {
            True { $customVersion }
            Default { $version.next($devTools.versionType) }
        }
        
        switch ($devTools.action)
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
                $appVeyor.pushArtifact($version.version)
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
