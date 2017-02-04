using module Logger

using module .\Config\IConfig.psm1

using module .\DesignPatterns\IObserver

Set-StrictMode -Version latest

class IService
{
    [ILogger]$logger
    [IConfig]$config
}

class IHelper
{
    [ILogger]$logger
    [IConfig]$config
}

class IHelperObservable: IObservable
{
    [ILogger]$logger
    [IConfig]$config
}

class IHelperObserver: IObserver
{
    [ILogger]$logger
    [IConfig]$config
}