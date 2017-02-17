using module ..\CommonInterfaces.psm1

using module ..\Service\LocalDeploymentService.psm1
using module ..\Service\RemoteDeploymentService.psm1
using module ..\Service\AppVeyorService.psm1
using module ..\Service\ModuleGeneratorService.psm1

Set-StrictMode -Version latest

class ActionFacade: IHelperObserver
{
    [AppVeyorService]$appVeyorService
    [ModuleGeneratorService]$moduleGeneratorService
    [LocalDeploymentService]$localDeploymentService
    [RemoteDeploymentService]$remoteDeploymentService
    
    [Void]update([IHelperObservable]$sender, [EventArgs]$event) { $this.($event.action)() }
    
    [Void]generateModule() { $this.moduleGeneratorService.generate() }
    
    [Void]copyToCurrentUserModules() { $this.localDeploymentService.copyDependencies() }
    
    [Void]install() { $this.localDeploymentService.symlinkDependencies() }
    
    [Void]uninstall() { $this.localDeploymentService.removeDependencies() }
    
    [Void]bumpVersion() { $this.config.version.applyNext() }
    
    [Void]publish() { $this.publish($null) }
    
    [Void]publish($bundle) { $this.remoteDeploymentService.publishToPSGallery($bundle) }
    
    [Void]deploy()
    {
        $this.bumpVersion()
        $bundle = $this.localDeploymentService.bundle()
        $this.publish($bundle)
    }
    
    [Void]test()
    {
        $testSuite = $this.config.serviceLocator.get('TestSuiteHelper')
        
        $this.logger.information('Execute PesterEntryPoint at {0}' -f $this.config.testsPath)
        . ('{0}\PesterEntryPoint' -f $this.config.testsPath)
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