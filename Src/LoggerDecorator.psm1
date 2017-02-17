using module Logger

class LoggerDecorator: Logger
{
    [Object]format($message)
    {
        $viewType = 'Format-{0}' -f (Get-PSCallStack)[$true].functionName
        return ($message | & $viewType | Out-String)
    }
    
    [void] list($message) { $this.debug($this.format($message)) }
    [void] table($message) { $this.debug($this.format($message)) }
}

class CuteEntry: Logger.ILoggerEntry
{
    static [Logger.ILoggerEntry]yield([String]$text)
    {
        $marks = ('?', '*', '+', '!', '!')
        
        [Logger.LoggingEventType]$eventType = (Get-PSCallStack)[$true].functionName

        return [Logger.ILoggerEntry]@{
            severity = $eventType
            message = '[{0}] {1}' -f $marks[([Int]$eventType)], $text.trim()
        }
    }
}
