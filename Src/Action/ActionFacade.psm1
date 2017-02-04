using module ..\CommonInterfaces.psm1
using module ..\Helper\FileSystemHelper.psm1
using module ..\Service\LocalDeploymentService.psm1
using module ..\Service\RemoteDeploymentService.psm1

Set-StrictMode -Version latest

class ActionFacade: IHelperObserver
{
    [LocalDeploymentService]$localDeploymentService
    [RemoteDeploymentService]$remoteDeploymentService
    [FileSystemHelper]$fileSystemHelper
    
    [Void]update([Object]$sender, [EventArgs]$event)
    {
        #$this.logger.list($this)
        $this.($event.action)()
    }
    
    [Void]GenerateProject() { }
    [Void]install()
    {
        $destination = '"{0}\{1}"' -f $this.config.modulesPath, $this.config.moduleName
        $source = '"{0}"' -f $this.config.modulePath
        
        
        Try
        {
            remove-item -ErrorAction Continue -Recurse -Force $destination
        } Catch
        {
            $this.logger.error($_.exception.message)
        }
        
        $this.logger.debug($destination)
        $this.logger.debug($source)
        
        $output = cmd /C mklink /J $destination $source 2>&1
        $this.logger.debug($output)
        
    }
    [Void]uninstall() { }
    [Void]test() { }
}