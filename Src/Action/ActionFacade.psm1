using module ..\CommonInterfaces.psm1

using module ..\Service\LocalDeploymentService.psm1
using module ..\Service\RemoteDeploymentService.psm1

Set-StrictMode -Version latest

class ActionFacade: IHelperObserver
{
    [IService]$appVeyorService
    [IService]$badgeService
    [IService]$moduleGeneratorService
    [LocalDeploymentService]$localDeploymentService
    [RemoteDeploymentService]$remoteDeploymentService
    
    [Void]update([IHelperObservable]$sender, [EventArgs]$event) { $this.($event.action)() }
    
    [Void]generateModule() { $this.moduleGeneratorService.generate() }
    
    [Void]copyToCurrentUserModules() { $this.localDeploymentService.copyDependencies() }
    
    [Void]install() { $this.localDeploymentService.symlinkDependencies() }
    
    [Void]uninstall() { $this.localDeploymentService.removeDependencies() }
    
    [Void]test() { $this.localDeploymentService.executeEntryPoint() }
    
    [Void]bumpVersion() { $this.config.version.applyNext() }
    
    [Void]publish() { $this.publish($null) }
    
    [Void]publish($bundle) { $this.remoteDeploymentService.publishToPSGallery($bundle) }
    
    [IO.DirectoryInfo]bundle() { return $this.localDeploymentService.bundle() }
    
    [Void]cleanup() { $this.cleanup($this.config.stagingPath) }
    
    [Void]cleanup($garbage) { $this.localDeploymentService.gc($garbage) }
    
    [Void]build() { $this.localDeploymentService.build($this.appVeyorService) }
    
    [Void]deploy()
    {
        $this.bumpVersion()
        $bundle = $this.bundle()
        $this.publish($bundle)
        $this.cleanup($bundle.parent.fullName)
    }
    
    [Void]updateBadges() { $this.badgeService.updateBadges() }
    
    #    [Void]createReleaseTag()
    #    {
    #        
    #    }
    #    
    #    [Void]release()
    #    {
    #        $this.deploy()
    #        $this.updateBadges()
    #        $this.createReleaseTag()
    #        
    #        #                $provision.gitCommitVersionChange($nextVersion)
    #        #                $provision.gitTag($nextVersion)
    #    }
    #    
    #    [Void]rollBack()
    #    {
    #        
    #    }
}