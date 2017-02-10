using module ..\CommonInterfaces.psm1
using module ..\Helper\FileSystemHelper.psm1
using module ..\Service\LocalDeploymentService.psm1
using module ..\Service\RemoteDeploymentService.psm1
using module ..\Service\AppVeyorService.psm1

using module ..\Helper\TestSuiteHelper.psm1

Set-StrictMode -Version latest

class ActionFacade: IHelperObserver
{
    [LocalDeploymentService]$localDeploymentService
    [RemoteDeploymentService]$remoteDeploymentService
    [AppVeyorService]$appVeyorService
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
        # Exposed test scope variables
        $config = $this.config
        #$logger = $this.logger
        
        $this.logger.warning('Before test')
        
        . ('{0}\PesterEntryPoint' -f $config.testsPath)
        
        #if (!$appVeyor) { return }
        #$appVeyor.uploadTestsFile($pesterConfig)
        #$appVeyor.throwOnFail($test.failedCount)
        $this.logger.warning('After test')
    }
}