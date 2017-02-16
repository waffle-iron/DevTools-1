# This script is invoked by DevTools,
# so it exists in the same scope
# and shares it's public variables:
# [ActionFacade]$this
# $this.config, $this.logger, $this.config.serviceLocator, etc

Set-StrictMode -Version latest

$global:ErrorActionPreference = 'Stop'
$global:progressPreference = 'SilentlyContinue'

$testSuite = $this.testSuiteHelper

$testSuite.coverage = $true
$testSuite.analyze = $true

[Void]$testSuite.AnalyzeScript($null)

$testSuite.invokePester($testSuite.getPesterDefaultConfig(@()))