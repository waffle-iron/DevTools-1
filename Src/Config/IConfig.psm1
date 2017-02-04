using module Logger

using module ..\GenericTypes.psm1

Set-StrictMode -Version latest

class IConfig {
    
    hidden [Hashtable]$storage = [Hashtable]::Synchronized(@{ })
    
    [String]$stagingPath = $ENV:TEMP
    [Boolean]$ci = $ENV:CI
    
    [Boolean]$whatIf
    
    [ILogger]$logger
    
    [Hashtable]$userSettings
    [Hashtable]$moduleManifest
    
    [Boolean]$isInProject
    
    [String]$currentDirectoryName
    [String]$moduleName
    
    [ActionType]$action
    [VersionComponent]$versionType
    
    [IO.DirectoryInfo]$modulesPath
    [IO.DirectoryInfo]$modulePath
    [IO.DirectoryInfo]$testsPath
    
    [IO.FileInfo]$readmeFile
    [IO.FileInfo]$manifestFile
    
    [Void]validateCurrentLocation() { throw }
    [Array]getProjects() { throw }
    [IO.DirectoryInfo]getProjectPath($moduleName){ throw }
    [Void]bindProperties([HashTable]$boundParameters) { throw }
}