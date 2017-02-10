using module .\IConfig.psm1
using module ..\GenericTypes.psm1

Set-StrictMode -Version latest

class DefaultConfig: IConfig
{
    DefaultConfig()
    {
        $this.modulesPath = ($ENV:psModulePath.split(';') |
            Where-Object { $_ -match 'Documents' }) | Select-Object -Unique
        
        $this.devToolsPath = '{0}\DevTools' -f $this.modulesPath
        $this.userSettings = Import-PowerShellDataFile ('{0}\.devtools' -f $ENV:USERPROFILE)
    }
    
    [Void]validateCurrentLocation()
    {
        $this.currentDirectoryName = ([IO.DirectoryInfo]$pwd.path).name
        $this.isInProject = Test-Path ('{0}\{1}.psd1' -f $pwd, $this.currentDirectoryName)
    }
    
    [Void]bindProperties([HashTable]$boundParameters)
    {
        $this.moduleName = $boundParameters['Module']
        $this.action = Get-Property $boundParameters Action ([ActionType]::Test)
        $this.versionType = Get-Property $boundParameters VersionType ([VersionComponent]::Build)
        $this.whatIf = Get-Property $boundParameters  WhatIf
        
        $this.currentUserModulePath = '{0}\{1}' -f $this.modulesPath, $this.moduleName
        
        $this.modulePath = $this.getProjectPath($this.moduleName)
        $this.testsPath = '{0}\Tests' -f $this.modulePath
        $this.readmeFile = '{0}\README.md' -f $this.modulePath
        $this.manifestFile = '{0}\{1}.psd1' -f $this.modulePath, $this.moduleName
        
        if ($this.manifestFile.exists)
        {
            $this.moduleManifest = Import-PowerShellDataFile $this.manifestFile
        }
        
        $this.moduleDependencies = @{ deploy = $true; name = $this.moduleName }
        $this.moduleDependencies += Get-Property $this.moduleManifest.PrivateData DevTools.Dependencies
        
        $this.version.version = $this.moduleManifest.ModuleVersion
    }
    
    [IO.DirectoryInfo]getProjectPath($moduleName)
    {
        return '{0}\{1}' -f $this.userSettings.projectsPath, $moduleName
    }
    
    [Array]getProjects()
    {
        return (Get-ChildItem -Directory $this.userSettings.projectsPath).forEach{ $_.name }
    }
}