using namespace System.Diagnostics.CodeAnalysis

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
    [SuppressMessageAttribute('PSUseSingularNouns', '')]
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
        $config.isInProject
        $logger.error('logger')
    }
    
}

New-Alias -Name dt -Value Use-DevTools