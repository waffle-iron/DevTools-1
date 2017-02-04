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