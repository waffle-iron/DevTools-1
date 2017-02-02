# This script is invoked by DevTools
# So it exists in the same scope
# And shares it's public variables:
# $devTools, $provision, $version, $appVeyor etc.

$appVeyor = $devTools.appVeyor

$pesterConfig = switch ([Boolean]$appVeyor)
{
    $true { $appVeyor.getPesterDefaultConfig($version.version) }
    $false { @{ path = $devTools.testsPath } }
}

# Disable Pester progress output.
$global:ProgressPreference = 'SilentlyContinue'

Remove-Module $devTools.projectName

$test = Invoke-Pester @pesterConfig

if (!$appVeyor) { return }

$appVeyor.uploadTestsFile($pesterConfig)
$appVeyor.throwOnFail($test.failedCount)