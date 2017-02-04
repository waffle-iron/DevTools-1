Set-StrictMode -Version latest


Import-Module DevTools
dt Install


return

$modulePath = 'D:\User\Development\OpenSource\Current\Powershell\DevTools'
$modulesPath = 'C:\Users\user\Documents\WindowsPowerShell\Modules'
$testsPath = "$modulePath\Tests"

if ($ENV:CI)
{
    $modulePath = 'C:\Projects\DevTools'
    $modulesPath = 'C:\Users\appveyor\Documents\WindowsPowerShell\Modules'
    $testsPath = "$modulePath\Tests"
}

Invoke-ScriptAnalyzer $modulePath\DevTools.psm1
Invoke-ScriptAnalyzer $modulePath\Src

$global:ProgressPreference = 'SilentlyContinue'

$sourceFiles = (
    @{ Path = "$modulesPath\DevTools\DevTools.psm1" },
    @{ Path = "$modulesPath\DevTools\Src\*" },
    @{ Path = "$modulesPath\DevTools\Src\Action\*" },
    @{ Path = "$modulesPath\DevTools\Src\Config\*" },
    @{ Path = "$modulesPath\DevTools\Src\DesignPatterns\*" },
    @{ Path = "$modulesPath\DevTools\Src\Helper\*" },
    @{ Path = "$modulesPath\DevTools\Src\Service\*" }
)

$pesterConfig = @{
    path = $testsPath + '\DevTools.Tests.ps1'
    CodeCoverage = $sourceFiles
}

$test = Invoke-Pester @pesterConfig