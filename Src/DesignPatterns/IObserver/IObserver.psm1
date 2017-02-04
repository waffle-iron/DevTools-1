using namespace System.Collections.Generic

Set-StrictMode -Version latest

class IObserver { [Void]update([Object]$sender, [EventArgs]$event) { throw } }

class IObservable
{
    [List[IObserver]]$observers = (New-Object List[IObserver])
    
    [void]attach([IObserver]$observer) { $this.observers.add($observer) }
    
    [void]detach([IObserver]$observer) { $this.observers.remove($observer) }
    
    [void]notify([EventArgs]$eventArgs)
    {
        foreach ($observer in $this.observers) { $observer.update($this, $eventArgs) }
    }
}