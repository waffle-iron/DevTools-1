Set-StrictMode -Version latest

$testSuite = $this.testSuiteHelper

$testSuite.analyze = $false
$testSuite.coverage = $false

[Void]$testSuite.AnalyzeScript($null)
$testSuite.invokePester($testSuite.getPesterDefaultConfig(@()))

$testSuite.analyze = $true
$testSuite.coverage = $true

$coverageSourceCode = (
    @{ path = 'Src\*' }
)

[Void]$testSuite.AnalyzeScript($null)
$testSuite.invokePester($testSuite.getPesterDefaultConfig($coverageSourceCode))