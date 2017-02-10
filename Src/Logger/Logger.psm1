using namespace System.Collections.Generic

using module .\ILogger.psm1
using module .\LoggerEntry.psm1

class Logger: ILogger
{
    [List[ILoggerAppender]]$appenders
    [Type]$logEntryType = [LoggerEntry]
    
    Logger()
    {
        $this.appenders = New-Object List[ILoggerAppender]
    }
    
    [void]log([ILoggerEntry]$entry)
    {
        $this.appenders | ForEach-Object{ $_.log([ILoggerEntry]$entry) }
    }
    
    [void] debug([String]$message) { $this.log($this.logEntryType::yield($message)) }
    [void] information([String]$message) { $this.log($this.logEntryType::yield($message)) }
    [void] warning([String]$message) { $this.log($this.logEntryType::yield($message)) }
    [void] error([String]$message) { $this.log($this.logEntryType::yield($message)) }
    [void] fatal([String]$message) { $this.log($this.logEntryType::yield($message)) }
}