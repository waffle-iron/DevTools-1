using module Logger

class IConfig {
    [Boolean]$whatIf
    
    [ILogger]$logger
    
    [Hashtable]$userSettings
    
    [Boolean]$isInProject
    
    [String]$currentDirectoryName
    
    [Void]validateCurrentLocation() { throw }
    [Array]getProjects() { throw }
}