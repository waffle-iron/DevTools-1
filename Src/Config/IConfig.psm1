using module Logger

using module ..\GenericTypes.psm1

Set-StrictMode -Version latest

class IConfig {
    
    hidden [Hashtable]$storage = [Hashtable]::Synchronized(@{ })
    
    [Collections.ICollection]$locale
    
    [String]$stagingPath = $ENV:TEMP
    
    [Boolean]$ci = $ENV:CI
    
    [Object]$version
    
    [Boolean]$whatIf
    [Boolean]$verbose = $false
    [Boolean]$debug = $false
    
    [ILogger]$logger
    
    [Hashtable]$userSettings
    [Hashtable]$moduleManifest
    
    [Array]$moduleDependencies
    
    [Boolean]$isInProject
    
    [String]$currentDirectoryName
    [String]$moduleName
    
    [ActionType]$action
    [VersionComponent]$versionType
    
    [IO.DirectoryInfo]$devToolsPath
    [IO.DirectoryInfo]$modulesPath
    [IO.DirectoryInfo]$modulePath
    [IO.DirectoryInfo]$currentUserModulePath
    [IO.DirectoryInfo]$testsPath
    
    [IO.FileInfo]$readmeFile
    [IO.FileInfo]$manifestFile
    
    [Void]validateCurrentLocation() { throw }
    [Void]bindProperties([HashTable]$boundParameters) { throw }
    
    [Array]getProjects() { throw }
    
    [IO.DirectoryInfo]getProjectPath($moduleName) { throw }
}