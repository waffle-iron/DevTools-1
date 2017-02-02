# This script is invoked by DevTools
# So it exists in the same scope
# And shares it's public variables:
# $devTools, $provision, $version, $appVeyor etc.

$appVeyor = $devTools.appVeyor

$pesterConfig = switch ([Boolean]$appVeyor)
{
    $true { $appVeyor.getPesterDefaultConfig($version.version) }
    $false {
        @{
            path = $devTools.testsPath
            #CodeCoverage = 'D:\User\Development\OpenSource\Current\Powershell\DevTools\Src\*'
            #CodeCoverage = 'C:\Users\user\Documents\WindowsPowerShell\Modules\DevTools\Src\*\*'
        }
    }
}

# Disable Pester progress output.
$global:ProgressPreference = 'SilentlyContinue'


$test = Invoke-Pester @pesterConfig


if (!$appVeyor) { return }

$appVeyor.uploadTestsFile($pesterConfig)
$appVeyor.throwOnFail($test.failedCount)