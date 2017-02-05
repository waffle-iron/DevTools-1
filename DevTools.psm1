using module Logger

using module .\Src\ServiceLocator.psm1
using module .\Src\Config\IConfig.psm1

Set-StrictMode -Version latest

$serviceLocator = New-Object ServiceLocator
[ILogger]$logger = $serviceLocator.get([ILogger])
[IConfig]$config = $serviceLocator.get([IConfig])

function Use-DevTools
{
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param
    (
        [Switch]$WhatIf,
        [Parameter(ValueFromRemainingArguments = $true)]
        $CustomVersion = $false
    )
    DynamicParam
    {
        return $serviceLocator.get('DynamicParametersHelper').build([ref]$psBoundParameters)
    }
    process
    {
        $config.bindProperties($psBoundParameters)
        $serviceLocator.get('ActionMapper').map()
    }
}

New-Alias -Name dt -Value Use-DevTools

& $PSScriptRoot\Src\Console\ArgumentCompleter

$logger.debug($config.locale.Loading)