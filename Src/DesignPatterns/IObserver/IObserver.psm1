using namespace System.Collections.Generic

Set-StrictMode -Version latest

class IObserver: IObserver[Object]
{
    [Void]update([Object]$sender, [EventArgs]$event) { throw }
    
    [Void] OnCompleted() { throw }
    [Void] OnError([Exception]$exception) { throw }
    [Void] OnNext([Object]$value) { throw }
}

class IObservable: IObservable[Object]
{
    [List[Object]]$observers = (New-Object List[Object])
    
    [void]attach([Object]$observer) { $this.observers.add($observer) }
    
    [void]detach([Object]$observer) { $this.observers.remove($observer) }
    
    [void]notify([EventArgs]$eventArgs)
    {
        foreach ($observer in $this.observers) { $observer.update($this, $eventArgs) }
    }
    
    [IDisposable] Subscribe([IObserver[Object]]$observer) { throw }
}