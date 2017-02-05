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
    
    [Void]update([Object]$sender, [EventArgs]$event) { $this.($event.action)() }
    
    [Void]GenerateProject() { }
    
    [Void]copyToCurrentUserModules()
    {
        $this.localDeploymentService.copyDependencies($this.fileSystemHelper)
    }
    
    [Void]install()
    {
        $this.localDeploymentService.symlinkDependencies($this.fileSystemHelper)
    }
    
    [Void]uninstall()
    {
        $this.localDeploymentService.removeDependencies($this.fileSystemHelper)
    }
    
    [Void]test()
    {
        $this.logger.warning('test')
    }
}