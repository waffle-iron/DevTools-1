using module ..\CommonInterfaces.psm1

Set-StrictMode -Version latest

class LocalDeploymentService: IService
{
    
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
    
    [Void]copyDependencies($fileSystemHelper)
    {
        $this.processDependencies({
                $this.logger.list($fileSystemHelper.synchronizeDirectory($source, $destination))
            })
    }
    
    [Void]symlinkDependencies($fileSystemHelper)
    {
        $this.processDependencies({
                $this.logger.debug($fileSystemHelper.createJunctionLink($source, $destination))
            })
    }
    
    [Void]removeDependencies($fileSystemHelper)
    {
        $this.processDependencies({
                $this.logger.list($fileSystemHelper.deleteItem($destination))
            })
    }
}