# This script is invoked by DevTools
# So it exists in the same scope
# And shares it's public variables:
# $devTools, $provision, $version, $appVeyor etc.

#$appVeyor = $devTools.appVeyor
#
#$pesterConfig = switch ([Boolean]$appVeyor)
#{
#    $true { $appVeyor.getPesterDefaultConfig($version.version) }
#    $false { @{ path = $devTools.testsPath } }
#}

# Disable Pester progress output.
#$global:ProgressPreference = 'SilentlyContinue'
#
#
#$modulePath = 'C:\Users\user\Documents\WindowsPowerShell\Modules'
#
#$sourceFiles = (
#    @{ Path = "$modulePath\DevTools\DevTools.psm1"; Function = 'Use-DevTools' }
#)
#
#$testsPath = 'D:\User\Development\OpenSource\Current\Powershell\DevTools\Tests'
#$pesterConfig = @{
#    path = $testsPath + '\Unit\zz.Tests.ps1'
#    CodeCoverage = $sourceFiles
#}
#
#
#$test = Invoke-Pester @pesterConfig

#if (!$appVeyor) { return }
#
#$appVeyor.uploadTestsFile($pesterConfig)
#$appVeyor.throwOnFail($test.failedCount)