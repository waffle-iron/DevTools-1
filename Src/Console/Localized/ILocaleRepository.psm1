using namespace System.Collections.Generic

using module Logger

using module ..\..\Config\IConfig.psm1

class ILocaleRepository: HashTable, IObserver[Object]
{
    [IConfig]$config
    [ILogger]$logger
    
    ILocaleRepository($dataBag)
    {
        $this.config = $dataBag.config
        $this.logger = $dataBag.logger
        
        (Import-LocalizedData -UICulture "en-US" -FileName 'locale' `
                              -BaseDirectory (
                '{0}\Src\Console\Localized' -f $this.config.devToolsPath
            )
        ).getEnumerator().forEach{ $this.add($_.key, $_.value) }
    }
    
    [Void] OnCompleted() { throw }
    [Void] OnError([Exception]$exception) { throw }
    [Void] OnNext([Object]$value) { throw }
    
    [Void]update([Object]$sender, [EventArgs]$event) { $this.renderTitle($event.action) }
}