using namespace System.Management.Automation

using module LibPosh




using module .\Src\Enums.psm1
using module .\Src\DynamicConfig.psm1

using module .\Src\Manager\IManager.psm1

Set-StrictMode -Version latest



#Param ()

[DynamicConfig]$script:devTools = $null



function Use-DevTools
{
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Scope = 'Function', Target = 'Use-DevTools')]
    param
    (
        [Switch]$WhatIf,
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
        $name, $action = $devTools.setProjectVariables($psBoundParameters)
        
        [IManager]$appVeyor = $devTools.appVeyorFactory()
        [IManager]$provision = $devTools.provisionFactory()
        [IManager]$version = $devTools.versionFactory()
        [IManager]$module = $devTools.moduleFactory()
        [IManager]$badge = $devTools.badgeFactory()
        
        $devTools.info($devTools.getTitle())
        
        $nextVersion = switch ([Boolean]$customVersion)
        {
            True { $customVersion }
            Default { $version.next($devTools.versionType) }
        }
        #        $badge.updateBadgs()
        #return
        
        switch ($action)
        {
            ([Action]::GenerateProject) { $module.create() }
            ([Action]::Install) { $provision.install() }
            ([Action]::Cleanup) { $provision.cleanup() }
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
                
                
                & $provision.entryPoint #Invoke-Expression
            }
            default { }
        }
    }
}

New-Alias -Name dt -Value Use-DevTools

& $PSScriptRoot\Src\ArgumentCompleter

Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Red 'First Run: Loading DevTools Module And Conole AutoCompleter'