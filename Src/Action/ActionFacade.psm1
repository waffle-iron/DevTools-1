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
    
    [Void]generateProject()
    {
    }
    
    [Void]copyToCurrentUserModules() { $this.localDeploymentService.copyDependencies() }
    
    [Void]install() { $this.localDeploymentService.symlinkDependencies() }
    
    [Void]uninstall() { $this.localDeploymentService.removeDependencies() }
    
    [Void]test()
    {
        # Exposed test scope variables
        $config = $this.config
        $logger = $this.logger
        
        $logger.debug('Execute PesterEntryPoint at {0}' -f $config.testsPath)
        
        . ('{0}\PesterEntryPoint' -f $config.testsPath)
    }
    
    [Void]build()
    {
        $bundle = $this.localDeploymentService.bundle()
        
        $archive = $this.localDeploymentService.archiveBundle($bundle)
        
        if ($this.config.ci) { $this.appVeyorService.pushArtifact($archive) }
        
        $this.logger.warning('Bundle GC {0}' -f $bundle.parent.name)
        
        $this.localDeploymentService.gc(($bundle.parent.fullName, $archive))
    }
}