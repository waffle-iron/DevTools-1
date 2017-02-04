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

    

    [IManager]$appVeyor
    [IManager]$provision
    [IManager]$version
    [IManager]$module
    [IManager]$badge
    
    $ciProvider = [AppVeyorManager]

    
    [Void] remove($object)
    {
        Remove-Item -Path $object -Recurse `
                    -ErrorAction Ignore -Verbose:$this.verbose
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
    

}