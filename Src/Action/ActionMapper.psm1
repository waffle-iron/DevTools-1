using module ..\DesignPatterns\IObserver

using module ..\GenericTypes.psm1
using module ..\CommonInterfaces.psm1

Set-StrictMode -Version latest

class ActionMapperEventArgs: EventArgs { [ActionType]$action }

class ActionMapper: IHelperObservable
{
    [Void]map()
    {
        $this.notify([ActionMapperEventArgs]@{ action = $this.config.action })
        
        switch ($this.config.action)
        {
            ([ActionType]::GenerateModule) { }
            ([ActionType]::Install) { }
            ([ActionType]::Uninstall) { }
            ([ActionType]::CopyToCurrentUserModules) { }
            ([ActionType]::BumpVersion) { }
            ([ActionType]::Publish) { }
            ([ActionType]::Deploy) { }
            ([ActionType]::Release) { }
            ([ActionType]::Test) { }
            ([ActionType]::Build) { }
        }
        
        $this.onCompleted()
    }
}