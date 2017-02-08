using module ..\Src\Config\DefaultConfig.psm1

Set-StrictMode -Version latest

$global:ErrorActionPreference = "Stop"
$global:progressPreference = 'SilentlyContinue'


#dt test
#return 

$config = New-Object DefaultConfig

Set-Variable MODULE_NAME DevTools -Option constant

$COVERAGE = $false
$SCRIPTANALYZER = $false

$modulesPath = $config.modulesPath

$modulePath = '{0}\{1}' -f $modulesPath, $MODULE_NAME

$testsPath = "$modulePath\Tests"

if ($SCRIPTANALYZER)
{
    Invoke-ScriptAnalyzer $modulePath\$MODULE_NAME.psm1
    Invoke-ScriptAnalyzer $modulePath\Src -Recurse
}

$sourceFiles = (
    @{ Path = "$modulePath\$MODULE_NAME.psm1" },
    @{ Path = "$modulePath\Src\*" },
    @{ Path = "$modulePath\Src\Action\*" },
    @{ Path = "$modulePath\Src\Config\*" },
    @{ Path = "$modulePath\Src\DesignPatterns\*" },
    @{ Path = "$modulePath\Src\Helper\*" },
    @{ Path = "$modulePath\Src\Service\*" }
)

$pesterConfig = @{
    path = $testsPath + '\Unit\Generic.Tests.ps1'
}

if ($COVERAGE) { $pesterConfig.add('CodeCoverage', $sourceFiles) }

$test = Invoke-Pester @pesterConfig