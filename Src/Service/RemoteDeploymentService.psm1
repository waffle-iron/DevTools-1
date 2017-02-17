using module ..\CommonInterfaces.psm1

Set-StrictMode -Version latest

class RemoteDeploymentService: IService
{
    [Void]publishToPSGallery($bandle)
    {
        $this.logger.warning('Publish the module to Powershell Gallery')
        if ($bandle) { $this.logger.information('Using bundle {0}' -f $bandle) }
        $this.logger.error('This could take some time!')
        
        if (-not $bandle) { $bandle = $this.config.modulePath }
        
        Publish-Module -Path $bandle `
                       -NuGetApiKey $this.config.userSettings.psGalleryApiKey `
                       -WhatIf:$this.config.whatIf `
                       -Verbose:$this.config.verbose
    }
}