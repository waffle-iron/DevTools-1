using module ..\Src\ServiceLocator.psm1

Set-StrictMode -Version latest

$global:ErrorActionPreference = "Stop"
$global:progressPreference = 'SilentlyContinue'

$serviceLocator = New-Object ServiceLocator

$config = $serviceLocator.get('IConfig')
$config.bindProperties(@{ module = 'DevTools' })

$testSuiteHelper = $serviceLocator.get('TestSuiteHelper')

$testSuiteHelper.coverage = $false
$testSuiteHelper.analyze = $false

[Void]$testSuiteHelper.AnalyzeScript($null)

$coverageSourceCode = (
    @{ path = 'Src\Action\*' },
    @{ path = 'Src\Config\*' },
    @{ path = 'Src\DesignPatterns\*' },
    @{ path = 'Src\Helper\*' },
    @{ path = 'Src\Service\*' }
)

$testSuiteHelper.invokePester($testSuiteHelper.getPesterDefaultConfig($coverageSourceCode))
