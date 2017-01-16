# Expose some globals.
$provision = $global:devTools.provision
$version = $global:devTools.version
$appVeyor = $global:devTools.appVeyor

$pesterConfig = switch ([Boolean]$appVeyor)
{
    $true { $appVeyor.getPesterDefaultConfig($provision, $version.version) }
    $false { @{ path = $provision.tests } }
}


# Disabling Pester progress output
$global:ProgressPreference = 'SilentlyContinue'

$test = Invoke-Pester @pesterConfig


if (!$appVeyor) { return }

$appVeyor.uploadTestsFile($provision, $pesterConfig)
$appVeyor.throwOnFail($provision, $test.FailedCount)