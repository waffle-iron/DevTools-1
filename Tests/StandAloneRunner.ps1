using module ..\Src\ServiceLocator.psm1

Set-StrictMode -Version latest

$global:ErrorActionPreference = 'Stop'
$global:progressPreference = 'SilentlyContinue'

$serviceLocator = New-Object ServiceLocator

$config = $serviceLocator.get('IConfig')
$config.bindProperties(@{ module = 'DevTools' })

$testSuiteHelper = $serviceLocator.get('TestSuiteHelper')

$testSuiteHelper.coverage = $true
$testSuiteHelper.analyze = $false

[Void]$testSuiteHelper.AnalyzeScript($null)

$coverageSourceCode = (
    @{ path = 'Src\Action\*' },
    @{ path = 'Src\Config\*' },
    @{ path = 'Src\DesignPatterns\*' },
    @{ path = 'Src\Helper\*' },
    @{ path = 'Src\Service\*' }
)

$pesterDefaultConfig = $testSuiteHelper.getPesterDefaultConfig($coverageSourceCode)

$pesterDefaultConfig.script = (
    @{ Path = ("{0}\Unit\Generic.Tests.ps1" -f $config.testsPath) },
    @{ Path = ("{0}\Unit\BasicAPI.Tests.ps1" -f $config.testsPath) }
)

$testSuiteHelper.invokePester($pesterDefaultConfig)


#Get-ChildItem -Filter "*.ps*" -Recurse | Get-Content | Measure-Object -Line -Word -Character