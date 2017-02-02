using namespace System.Diagnostics.CodeAnalysis

using module Logger

using module .\Src\Config\DefaultConfig.psm1
using module .\Src\Helpers\DynamicParametersHelper.psm1


class CustomEntry: Logger.ILoggerEntry
{
    static [Logger.ILoggerEntry]yield([String]$text)
    {
        return [Logger.ILoggerEntry]@{
            severity = [Logger.LoggingEventType]::((Get-PSCallStack)[$true].functionName)
            message = '{1}xxx {0} xxx{1}' -f $text, [Environment]::NewLine
        }
    }
}

class CustomAppender: Logger.ILoggerAppender
{
    [void]log([Logger.ILoggerEntry]$entry)
    {
        Write-Host $entry.message -ForegroundColor Blue 
    }
}

#Write-Host(Get-Module | Format-Table|Out-String)

Set-StrictMode -Version latest
$logger = $null

$logger = New-Object Logger
#$logger.logEntryType = [CustomEntry]
#$logger.appenders.add([CustomAppender]@{ })

$logger.logEntryType = [Logger.LoggerEntryTrimmed]
$logger.appenders.add([Logger.ColoredConsoleAppender]@{ })


$logger2 = New-Object Logger
$logger2.logEntryType = [CustomEntry]
$logger2.appenders.add([CustomAppender]@{ })


$configContainer = [DefaultConfig]@{ logger = $logger }

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
        
        $configContainer.validateCurrentLocation()
        
        $dynamicParametersHelper = [DynamicParametersHelper]@{ configContainer = $configContainer }
        return $dynamicParametersHelper.build([ref]$psBoundParameters)
    }
    
    process
    {
        $configContainer.isInProject
        $logger.error('logger1')
        $logger2.error('text')
      #@$logger.error('aaaaaaaaaa'+[Environment]::NewLine)
    }
    
}
New-Alias -Name dt -Value Use-DevTools