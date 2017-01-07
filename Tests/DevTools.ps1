using module DevTools

param ($action = [DevTools.Action]::Development)

$provision = [DevTools.ProvisionManager]@{ action = $action; root = $PSScriptRoot }
$version = [DevTools.VersionManager]@{ psd = $provision.psd }

$provision.dependencies = (
@{
    deploy = $true
    name = $provision.projectName
}
)

$provision.report('Version:{0}' -f [String]$version.version)
$provision.report('Action:{0}' -f $provision.action)

$nextVersion = $version.next([DevTools.VersionComponent]::Build)

switch ($provision.action)
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

if ($provision.action -ne [Action]::Development) { return }

$provision.report('The Test Environment is redy.')

. $provision.entryPoint


























