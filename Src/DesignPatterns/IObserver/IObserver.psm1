using namespace System.Collections.Generic

Set-StrictMode -Version latest

class IObserver: IObserver[Object]
{
    [Void]Update([Object]$sender, [EventArgs]$event) { throw }
    [Void]OnNext([Object]$value) { throw }
    [Void]OnCompleted() { throw }
    [Void]OnError([Exception]$exception) { throw }
}

class IObservable: IObservable[Object]
{
    [List[Object]]$observers = (New-Object List[Object])
    
    [IDisposable]Subscribe([IObserver[Object]]$observer) { return $this.observers.add($observer) }
    
    [Void]Unsubscribe([Object]$observer) { $this.observers.remove($observer) }
    
    [Void]Notify([EventArgs]$eventArgs)
    {
        foreach ($observer in $this.observers) { $observer.update($this, $eventArgs) }
    }
    
    [Void]OnCompleted()
    {
        foreach ($observer in $this.observers)
        {
            try { $observer.onCompleted() } catch { 'Not Implemented' }
        }
    }
}