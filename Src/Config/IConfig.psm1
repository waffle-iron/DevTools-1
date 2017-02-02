#using module ..\Logger\ILogger.psm1
#using module Logger.ILogger
#[Logger.ILogger]

class IConfig {
    $logger
    
    [Hashtable]$userSettings
    
    [Boolean]$whatIf
    
    [Boolean]$isInProject
    
    [String]$currentDirectoryName
    
    [Void]validateCurrentLocation() { throw }
}