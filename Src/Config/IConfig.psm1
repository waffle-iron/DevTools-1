using module Logger

using module ..\GenericTypes.psm1
using module ..\DesignPatterns\IServiceLocator

Set-StrictMode -Version latest

class IConfig {
    
    [IServiceLocator]$serviceLocator
    [ILogger]$logger
    
    hidden [Hashtable]$storage = [Hashtable]::Synchronized(@{ })
    
    [Collections.ICollection]$locale
    
    [String]$stagingPath = $ENV:TEMP
    
    [Boolean]$ci = $ENV:CI
    
    [PSObject]$version
    
    [Boolean]$whatIf
    [Boolean]$verbose = $false
    [Boolean]$debug = $false
    
    [Hashtable]$userSettings
    [Hashtable]$moduleManifest
    
    [Array]$moduleDependencies
    
    [Boolean]$isInProject
    
    [String]$currentDirectoryName
    [String]$moduleName
    
    [ActionType]$action
    
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