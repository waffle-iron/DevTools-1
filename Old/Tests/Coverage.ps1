#using module ..\Src\IoC.psm1

$global:ProgressPreference = 'SilentlyContinue'


$modulePath = 'C:\Users\user\Documents\WindowsPowerShell\Modules'
$testsPath = 'D:\User\Development\OpenSource\Current\Powershell\DevTools\Tests'

$sourceFiles = (
    #@{ Path = "$modulePath\DevTools\DevTools.psm1"; Function = 'Use-DevTools' }
    @{ Path = "$modulePath\DevTools\DevTools.psm1" } `
    #,@{ Path = "$modulePath\DevTools\Src\DynamicConfig.psm1" }
)


$pesterConfig = @{
    path = $testsPath + '\Unit\DevTools.Tests.ps1'
    CodeCoverage = $sourceFiles
}

$test = Invoke-Pester @pesterConfig
