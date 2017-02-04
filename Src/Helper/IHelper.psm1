using module Logger

using module ..\Config\IConfig.psm1

class IHelper{
    [ILogger]$logger
    [IConfig]$config
}