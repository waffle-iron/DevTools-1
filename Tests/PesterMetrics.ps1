

#$PSScriptRoot
#$MyInvocation


#$modulePath = 'D:\User\Development\OpenSource\Current\Powershell\DevTools'
#$modulesPath = 'C:\Users\user\Documents\WindowsPowerShell\Modules'
#$testsPath = "$modulePath\Tests"
#
#Invoke-ScriptAnalyzer $modulePath\DevTools.psm1
#Invoke-ScriptAnalyzer $modulePath\Src
#
#$global:ProgressPreference = 'SilentlyContinue'
#
#$sourceFiles = (
#    #@{ Path = "$modulePath\DevTools\DevTools.psm1"; Function = 'Use-DevTools' }
#    @{ Path = "$modulesPath\DevTools\DevTools.psm1" } `
#, @{ Path = "$modulesPath\DevTools\Src\Config\*" } `
#, @{ Path = "$modulesPath\DevTools\Src\Dispatchers\*" } `
#    ,@{ Path = "$modulesPath\DevTools\Src\Helpers\*" } `
#    #,@{ Path = "$modulePath\DevTools\Src\DynamicConfig.psm1" }
#)
#
#$pesterConfig = @{
#    path = $testsPath + '\DevTools.Tests.ps1'
#    CodeCoverage = $sourceFiles
#}
Import-Module DevTools
dt
#$test = Invoke-Pester @pesterConfig