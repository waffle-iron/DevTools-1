
# Outdated !!!

using module DevTools

param ($action = [DevTools.Action]::Development)

[DevTools.Action]$action = $action

$provision = [DevTools.ProvisionManager]@{ root = $PSScriptRoot }
$version = [DevTools.VersionManager]@{ psd = $provision.psd }

$projectConfig = Import-PowerShellDataFile $provision.psd

$provision.dependencies = (
    @{
        deploy = $true
        name = $provision.projectName
    }
)

$provision.dependencies += $projectConfig.PrivateData.DevTools.Dependencies

$provision.report('Version:{0}' -f [String]$version.version)
$provision.report('Action:{0}' -f $action)

$nextVersion = $version.next([DevTools.VersionComponent]::Build)

switch ($action)
{
    ([DevTools.Action]::Cleanup) { $provision.cleanup() }
    ([DevTools.Action]::Shortcuts) { $provision.shortcuts() }
    ([DevTools.Action]::Copy) { $provision.copy() }
    ([DevTools.Action]::BumpVersion) { $provision.bumpVersion($version, $nextVersion) }
    ([DevTools.Action]::Publish) { $provision.publish() }
    ([DevTools.Action]::Deploy)
    {
        $provision.bumpVersion($version, $nextVersion)
        $provision.publish()
    }
    default { }
}

if ($action -ne [DevTools.Action]::Development) { return }

$provision.report('The Test Environment is redy.')

. $provision.entryPoint
