using namespace System.Management.Automation

using module .\Src\Enums.psm1
using module .\Src\DynamicConfig.psm1

using module .\Src\Manager\AppVeyorManager.psm1
using module .\Src\Manager\BadgeManager.psm1
using module .\Src\Manager\ModuleManager.psm1
using module .\Src\Manager\ProvisionManager.psm1
using module .\Src\Manager\VersionManager.psm1


Set-StrictMode -Version latest

[DynamicConfig]$global:devTools = $null

function Use-DevTools
{
    [CmdletBinding()]
    param
    (
        [Switch]$WhatIf,
        [Parameter(ValueFromRemainingArguments = $true)]
        $CustomVersion = $false
    )
    
    DynamicParam
    {
        $global:devTools = $devTools = New-Object DynamicConfig
        
        $devTools.setEnvironment()
        
        return $devTools.dynamicParameters([ref]$psBoundParameters)
    }
    process
    {
        $name, $action = $devTools.setProjectVariables($psBoundParameters)
        
        [AppVeyorManager]$appVeyor = $devTools.appVeyorFactory()
        [ProvisionManager]$provision = $devTools.provisionFactory()
        [VersionManager]$version = $devTools.versionFactory()
        [ModuleManager]$module = $devTools.moduleFactory()
        [BadgeManager]$badge = $devTools.badgeFactory()
        
        $devTools.info($devTools.getTitle())
        
        $nextVersion = switch ([Boolean]$customVersion)
        {
            True { $customVersion }
            Default { $version.next($devTools.versionType) }
        }
        
        $badge.updateBadgs()
        return
        switch ($action)
        {
            ([Action]::GenerateProject) { $module.create() }
            ([Action]::Install){ $provision.install() }
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
                
                Invoke-Expression $provision.entryPoint
            }
            default { }
        }
    }
}

New-Alias -Name dt -Value Use-DevTools

Invoke-Expression $PSScriptRoot\Src\ArgumentCompleter

Write-Host -ForegroundColor Red 'First Run: Loading DevTools Module And Conole AutoCompleter'