using module LibPosh

using module .\Enums.psm1

using module .\Manager\IManager.psm1
using module .\Manager\AppVeyorManager.psm1
using module .\Manager\BadgeManager.psm1
using module .\Manager\ProvisionManager.psm1
using module .\Manager\VersionManager.psm1
using module .\Manager\ModuleManager.psm1

using module .\Logger\ILogger.psm1
using module .\Logger\Logger.psm1
Using module .\Logger\LoggerEntryTrimmed.psm1
Using module .\Logger\Appenders\ColoredConsoleAppender.psm1
Using module .\Logger\Appenders\AppVeyorAppender.psm1

Set-StrictMode -Version latest

class DynamicConfig {
    
    [Boolean]$verbose = $false
    
    [ILogger]$logger
    
    [Hashtable]$storage = [Hashtable]::Synchronized(@{ })
    
    [Hashtable]$userSettings = @{ file = ('{0}\dev_tools_config.psd1' -f $env:USERPROFILE) }
    
    [Boolean]$isInProject
    [Boolean]$whatIf
    
    [String]$currentDirectoryName
    [String]$stagingPath = $env:temp
    [String]$modulesPath = 'Documents'
    [String]$modulePath
    [String]$testsPath = '{0}\Tests'
    [String]$readmePath = '{0}\README.md'
    
    [IO.FileInfo]$psdFile = '{0}\{1}.psd1'
    [Hashtable]$moduleSettings
    
    [String]$projectName
    [Action]$action
    [VersionComponent]$versionType
    
    [IManager]$appVeyor
    [IManager]$provision
    [IManager]$version
    [IManager]$module
    [IManager]$badge
    
    $ciProvider = [AppVeyorManager]
    [Boolean]$ci = $env:CI
    
    [Void]info($text) { $this.logger.information($text) }
    [Void]warning($text) { $this.logger.warning($text) }
    [Void]error($text) { $this.logger.error($text) }
    [Void]debug($text) { $this.logger.debug($text) }
    
    [Array]getProjects()
    {
        return (Get-ChildItem -Directory $this.userSettings.projectsPath).forEach{ $_.name }
    }
    
    [Void] remove($object)
    {
        Remove-Item -Path $object -Recurse `
                    -ErrorAction Ignore -Verbose:$this.verbose
    }
    
    DynamicConfig()
    {
        $this.logger = New-Object Logger
        $this.logger.logEntryType = [LoggerEntryTrimmed]
        $this.logger.appenders.add([ColoredConsoleAppender]@{ })
        
        $this.modulesPath = ($Env:psModulePath.split(';') |
            Where-Object { $_ -match $this.modulesPath }) | Select-Object -Unique
    }
    
    [Void]setEnvironment()
    {
        $this.userSettings = switch ([Boolean]$this.ci)
        {
            true{ $this.ciProvider::getConfig() }
            false{ Import-PowerShellDataFile $this.userSettings.file }
        }
        
        [IO.DirectoryInfo]$location = Get-Item -Path $pwd
        $path = $location.fullName
        $this.currentDirectoryName = $location.name
        $this.isInProject = Test-Path ('{0}\{1}.psd1' -f $path, $this.currentDirectoryName)
    }
    
    [Array]setProjectVariables($boundParameters)
    {
        
        $this.projectName = $boundParameters['Project']
        $this.action = $boundParameters['Action']
        $this.versionType = $boundParameters['VersionType']
        $this.whatIf = $boundParameters['WhatIf']
        
        $this.modulePath = $this.getProjectPath($this.projectName)
        
        $this.testsPath = $this.testsPath -f $this.modulePath
        
        $this.readmePath = $this.readmePath -f $this.modulePath
        
        $this.psdFile = $this.psdFile -f $this.modulePath, $this.projectName
        
        if ($this.psdFile.exists) { $this.moduleSettings = Import-PowerShellDataFile $this.psdFile }
        
        return ($this.projectName, $this.action)
    }
    
    [AppVeyorManager]appVeyorFactory()
    {
        if ([Boolean]$this.ci)
        {
            $this.appVeyor = [AppVeyorManager]@{
                devTools = $this
            }
            $this.logger.appenders.add([AppVeyorAppender]@{ })
        }
        return $this.appVeyor
    }
    
    [ProvisionManager]provisionFactory()
    {
        $this.provision = [ProvisionManager]@{
            devTools = $this
            project = $this.projectName
        }
        return $this.provision
    }
    
    [VersionManager]versionFactory()
    {
        $this.version = [VersionManager]@{
            devTools = $this
        }
        return $this.version
    }
    
    [ModuleManager]moduleFactory()
    {
        $this.module = [ModuleManager]@{
            devTools = $this
            verbose = $this.verbose
            projectName = $this.projectName
            stagingPath = $this.stagingPath
            
        }
        return $this.module
    }
    
    [BadgeManager]badgeFactory()
    {
        $this.badge = [BadgeManager]@{
            devTools = $this
            verbose = $this.verbose
            projectName = $this.projectName
            stagingPath = $this.stagingPath
            modulePath = $this.modulePath
            readmePath = $this.readmePath
            version = $this.version.version
            requiredModules = Get-Property $this.moduleSettings RequiredModules
        }
        return $this.badge
    }
    
    [String]getProjectPath($moduleName)
    {
        return '{0}\{1}' -f $this.userSettings.projectsPath, $moduleName
    }
    
    [String]getTitle()
    {
        $cpu_architecture = switch ([Boolean]$env:PLATFORM)
        {
            true { 'CI {0}' -f $env:PLATFORM }
            false { $env:PROCESSOR_ARCHITECTURE }
        }
        
        $title = '{5}{0} {1} {2} [{3} {4}]{5}' -f $this.projectName, $this.version.version, `
        $this.action, $cpu_architecture, $env:COMPUTERNAME, [Environment]::NewLine
        return $title
    }
    
    [Object]dynamicParameters([ref]$boundParameters)
    {
        $dpf = New-Object LibPosh.DynamicParameter
        
        # Project
        $projectField = 'Project'
        $parameterAttribute = $dpf.getParameterAttribute(@{ position = 1; mandatory = $true })
        
        if ($this.isInProject)
        {
            $parameterAttribute.position = 2
            $parameterAttribute.mandatory = $false
            $boundParameters.value[$projectField] = $this.currentDirectoryName
        }
        
        $projects = $this.getProjects()
        
        $rawParameters = -split $myinvocation.line
        
        [Boolean]$generateProject = $rawParameters -contains 'GenerateProject'
        
        if ($generateProject)
        {
            $newProject = switch ($rawParameters[$true] -eq 'GenerateProject')
            {
                true { $rawParameters[2] }
                false { $rawParameters[1] }
            }
            
            if ($projects -notcontains $newProject)
            {
                $parameterAttribute.mandatory = $false
                $projects += $newProject
            }
        }
        
        [Void]$dpf.set($parameterAttribute, $projects, $projectField)
        
        # Action
        $actionField = 'Action'
        
        $parameterAttribute = $dpf.getParameterAttribute()
        $parameterAttribute.mandatory = $false
        $parameterAttribute.position = switch ($this.isInProject)
        {
            True { 1 }
            Default { 2 }
        }
        
        $boundParameters.value[$actionField] = [Action]::Test
        
        [Void]$dpf.set($parameterAttribute, [Enum]::getValues([Action]), $actionField)
        
        # VersionType
        $versionField = 'VersionType'
        $parameterAttribute = $dpf.getParameterAttribute(@{ position = 3 })
        $parameterAttribute.mandatory = $false
        $parameterAttribute.position = 3
        $boundParameters.value[$versionField] = [VersionComponent]::Build
        
        return $dpf.set($parameterAttribute, ('Major', 'Minor', 'Build'), $versionField)
    }
}