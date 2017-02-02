using module ..\ILogger.psm1

class ColoredConsoleAppender: ILoggerAppender
{
    static $debugColor = [ConsoleColor]::DarkYellow
    static $informationColor = [ConsoleColor]::DarkGreen
    static $warningColor = [ConsoleColor]::Yellow
    static $errorColor = [ConsoleColor]::Red
    static $fatalColor = [ConsoleColor]::Red
    
    [void]log([ILoggerEntry]$entry)
    {
        Write-Host $entry.message `
                   -ForegroundColor ([ColoredConsoleAppender]::('{0}Color' -f $entry.severity))
    }
}