using module ..\CommonInterfaces.psm1

Set-StrictMode -Version latest

class LocalDeploymentService: IService
{
    [Object]$fileSystemHelper
    
    [String]getSource($module) { return $this.config.getProjectPath($module) }
    
    [String]getDestination($module) { return '{0}\{1}' -f $this.config.modulesPath, $module }
    
    [Void]processDependencies([Scriptblock]$callback)
    {
        $this.config.moduleDependencies.where({ $_ -ne $null }).forEach{
            if ($_.deploy)
            {
                $source = $this.getSource($_.name)
                $destination = $this.getDestination($_.name)
                
                $callback.invoke($source, $destination)
            }
        }
    }
    
    [Void]copyDependencies()
    {
        $this.processDependencies({
                $this.logger.list(
                    $this.fileSystemHelper.synchronizeDirectory($source, $destination)
                )
            })
    }
    
    [Void]symlinkDependencies()
    {
        $this.processDependencies({
                $this.logger.debug(
                    $this.fileSystemHelper.createJunctionLink($source, $destination)
                )
            })
    }
    
    [Void]removeDependencies()
    {
        $this.processDependencies({
                $this.logger.list($this.fileSystemHelper.deleteItem($destination))
            })
    }
    
    [IO.DirectoryInfo]bundle()
    {
        $bundleId = [guid]::newGuid()
        
        $this.logger.warning('Stage bundle {0}' -f $bundleId)
        
        $basePath = '{0}\{1}\{2}' -f $this.config.stagingPath, $bundleId, $this.config.moduleName
        
        Get-ChildItem $this.config.modulePath -Recurse | ForEach-Object { $_.Attributes = '' }
        
        foreach ($file in -split $this.config.moduleManifest.fileList)
        {
            [IO.FileInfo]$fileInfo = '{0}\{1}' -f $this.config.modulePath, $file
            
            $destination = '{0}\{1}' -f $basePath, $file
            
            if ($fileInfo.exists -or $fileInfo.Attributes -eq [IO.FileAttributes]::Directory)
            {
                $this.logger.list($this.fileSystemHelper.copyItem($fileInfo, $destination))
            }
        }
        
        return [IO.DirectoryInfo]$basePath
    }
    
    [IO.DirectoryInfo]archiveBundle([IO.DirectoryInfo]$bundle)
    {
        $destination = '{0}\{1}-{2}.zip' -f (
            $this.config.stagingPath,
            $this.config.moduleName,
            $this.config.version
        )
        
        $this.logger.warning('Compress bundle {0}' -f $destination)
        $this.logger.list($this.fileSystemHelper.archive($bundle, $destination))
        
        return $destination
    }
    
    [Void]gc([Array]$items)
    {
        foreach ($item in $items)
        {
            $this.logger.list($this.fileSystemHelper.deleteItem($item))
        }
        
    }
    
    [Void]executeEntryPoint()
    {
        if ($env:APPVEYOR_REPO_TAG -eq $true)
        {
            $this.config.error('Task [Test] is not allowed on Tag branches!')
            return
        }
        
        $testSuite = $this.config.serviceLocator.get('TestSuiteHelper')
        
        $this.logger.information('Execute PesterEntryPoint at {0}' -f $this.config.testsPath)
        
        . ('{0}\PesterEntryPoint' -f $this.config.testsPath)
    }
    
    [Void]build($appVeyorService)
    {
        # if (-not $this.localDeploymentService.authorizedToBuild()) { return }
        
        if ($false -eq $env:APPVEYOR_REPO_TAG)
        {
            $this.config.error('Task [Build] is not allowed on {0}!' -f $env:APPVEYOR_REPO_BRANCH)
            return
        }
        
        $bundle = $this.bundle()
        $archive = $this.archiveBundle($bundle)
        
        if ($this.config.ci) { $appVeyorService.pushArtifact($archive) }
        
        $this.gc(($bundle.parent.fullName, $archive))
    }
    
}