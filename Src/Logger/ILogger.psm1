using namespace System.Collections.Generic


class ILogger
{
    [void]debug([String]$message) { }
    [void]information([String]$message) { }
    [void]warning([String]$message) { }
    [void]error([String]$message) { }
    [void]fatal([String]$message) { }
}


class ILoggerAppender
{
    [void]log([LogEntry]$entry) { }
}


enum LoggingEventType
{
    Secure
    Debug
    Information
    Warning
    Error
    Fatal
}


class LogEntry
{
    [ValidatePattern('\w')]
    [LoggingEventType]$severity
    
    [ValidateNotNullOrEmpty()]
    [String]$message
    [Exception]$exception = $null
    
    static [LogEntry]yield([String]$text)
    {
     
        $text = $text.trim()
        
        return [LogEntry]@{
            severity = [LoggingEventType]::((Get-PSCallStack)[$true].functionName)
            message = $text
        }
    }
}


class ColoredConsoleAppender: ILoggerAppender
{
    static $debugColor = [ConsoleColor]::DarkYellow
    static $informationColor = [ConsoleColor]::DarkGreen
    static $warningColor = [ConsoleColor]::Yellow
    static $errorColor = [ConsoleColor]::Red
    static $fatalColor = [ConsoleColor]::Red
    
    [void]log([LogEntry]$entry)
    {
        Write-Host $entry.message `
                   -ForegroundColor ([ColoredConsoleAppender]::('{0}Color' -f $entry.severity))
    }
}

class AppVeyorAppender: ILoggerAppender
{
    [void]log([LogEntry]$entry)
    {
        Add-AppveyorMessage $entry.message -Category ([String]$entry.severity)
    }
}


class Logger: ILogger
{
    [List[ILoggerAppender]]$appenders = (New-Object List[ILoggerAppender])
    
    [void]log([LogEntry]$entry)
    {
        $this.appenders | ForEach-Object{
            $_.log([LogEntry]$entry)
        }
    }
    
    [void] debug([String]$message) { $this.log([LogEntry]::yield($message)) }
    [void] information([String]$message) { $this.log([LogEntry]::yield($message)) }
    [void] warning([String]$message) { $this.log([LogEntry]::yield($message)) }
    [void] error([String]$message) { $this.log([LogEntry]::yield($message)) }
    [void] fatal([String]$message) { $this.log([LogEntry]::yield($message)) }
}