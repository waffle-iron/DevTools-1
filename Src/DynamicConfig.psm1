using namespace System.Management.Automation

using module .\Types.psm1

using module .\DynamicParameter.psm1

using module .\AppVeyorManager.psm1
using module .\ProvisionManager.psm1
using module .\VersionManager.psm1
using module .\ModuleManager.psm1

class DynamicConfig {
    
    [Hashtable]$devTools = [Hashtable]::Synchronized(@{ })
    
    [String]$userSettingsFile = '{0}\dev_tools_config.psd1' -f $env:USERPROFILE
    [Hashtable]$userSettings
    
    [String]$modules = 'Documents'
    
    [String]$project
    [Boolean]$isInProject
    [Boolean]$whatIf = $false
    
    [AppVeyorManager]$appVeyor
    [ProvisionManager]$provision
    [VersionManager]$version
    [ModuleManager]$module
    
    [String]$cr = [Environment]::NewLine
    
    [Void]log($text, $color, $category)
    {
        $text = $text.trim()
        if ([String]::IsNullOrEmpty($text)) { return }
        
        if ($this.appVeyor) { $this.appVeyor.message($text, $category) }
        Write-Host $text -ForegroundColor $color
    }
    
    [Void]info($text) { $this.log($text, [ConsoleColor]::DarkGreen, 'Information') }
    [Void]warning($text) { $this.log($text, [ConsoleColor]::Yellow, 'Warning') }
    [Void]error($text) { $this.log($text, [ConsoleColor]::Red, 'Error') }
    
    [Array]getProjects()
    {
        return (Get-ChildItem $this.userSettings.projectsPath).forEach{
            if ($_.length -eq $true) { $_.name }
        }
    }
    
    DynamicConfig()
    {
        $this.userSettings = Import-PowerShellDataFile $this.userSettingsFile
        
        if ([Boolean]$env:CI)
        {
            $this.appVeyor = New-Object AppVeyorManager $this
            $this.userSettings = $this.appVeyor.getConfig()
        }
        
        $this.modules = ($Env:psModulePath.split(';') |
            Where-Object { $_ -match $this.modules }) | Select-Object -Unique
    }
    
    [Void]setEnvironment()
    {
        [IO.DirectoryInfo]$location = Get-Item -Path $pwd
        $path = $location.FullName
        $this.project = $location.Name
        $this.isInProject = Test-Path ('{0}\{1}.psd1' -f $path, $this.project)
    }
    
    [ProvisionManager]provisionFactory($moduleName)
    {
        $this.provision = [ProvisionManager]@{
            config = $this
            project = $moduleName
        }
        return $this.provision
    }
    
    [VersionManager]versionFactory()
    {
        $this.version = [VersionManager]@{ psd = $this.provision.psd }
        return $this.version
    }
    
    [ModuleManager]ModuleFactory($moduleName)
    {
        $this.module = [ModuleManager]@{
            config = $this
            moduleName = $moduleName
        }
        return $this.module
    }
    
    [String]getProjectPath($moduleName)
    {
        return '{0}\{1}' -f $this.userSettings.projectsPath, $moduleName
    }
    
    [Object]dynamicParameters([ref]$boundParameters)
    {
        $generateProject = $boundParameters.value['generateProject']
        
        $dpf = New-Object DynamicParameter
        
        $runtimeParameterDictionary = $dpf.runtimeParameterDictionary
        
        # Project
        $projectName = 'Project'
        $parameterAttribute = New-Object ParameterAttribute
        
        if ($this.isInProject)
        {
            $parameterAttribute.position = 2
            $boundParameters.value[$projectName] = $this.project
        } else
        {
            $parameterAttribute.position = 1
            $parameterAttribute.mandatory = $true
        }
        
        if ([Boolean]$generateProject)
        {
            $parameterAttribute.mandatory = $false
        }
        
        [Void]$dpf.set($parameterAttribute, $this.getProjects(), $projectName)
        
        # Action
        $actionName = 'Action'
        
        $parameterAttribute = New-Object ParameterAttribute
        $parameterAttribute.mandatory = $false
        $parameterAttribute.position = switch ($this.isInProject)
        {
            True { 1 }
            Default { 2 }
        }
        
        $boundParameters.value[$actionName] = [Action]::Test
        
        [Void]$dpf.set($parameterAttribute, [Enum]::getValues([Action]), $actionName)
        
        # VersionType
        $versionName = 'VersionType'
        $parameterAttribute = New-Object ParameterAttribute
        $parameterAttribute.mandatory = $false
        $parameterAttribute.position = 3
        $boundParameters.value[$versionName] = [VersionComponent]::Build
        
        return $dpf.set($parameterAttribute, ('Major', 'Minor', 'Build'), $versionName)
    }
}