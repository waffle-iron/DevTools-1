   
    [Boolean]$verbose = $false

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

}