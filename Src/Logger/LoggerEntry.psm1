using module .\ILogger.psm1

class LoggerEntry: ILoggerEntry
{
    [ValidatePattern('\w')]
    [LoggingEventType]$severity
    
    [ValidateNotNullOrEmpty()]
    [String]$message
    [Exception]$exception = $null
    
    static [ILoggerEntry]yield([String]$text)
    {
        return [ILoggerEntry]@{
            severity = [LoggingEventType]::((Get-PSCallStack)[$true].functionName)
            message = $text
        }
    }
}