using module Logger

using module ..\CommonInterfaces.psm1

Set-StrictMode -Version latest

class AppVeyorService: IService
{
    [String]$apiLink = 'https://ci.appveyor.com/api/testresults/nunit/{0}'
    
    [IService]getInstance()
    {
        $this.logger.appenders.add([Logger.AppVeyorAppender]@{ })
        return $this
    }
    
    [Void]pushArtifact($archive)
    {
        $this.logger.warning('Pushing bundle to "Appveyor" as {0}' -f $this.config.moduleName)
        
        Push-AppveyorArtifact -Path $archive `
                              -DeploymentName $this.config.moduleName -Verbose
    }
    
    [Void]processPesterResults($pesterResults, $pesterConfig)
    {
        $this.uploadTestsFile($pesterConfig.outputFile)
        $this.throwOnFail($pesterResults.failedCount)
       
    }
    
    [Void]uploadTestsFile($outputFile)
    {
        $target = $this.apiLink -f $ENV:APPVEYOR_JOB_ID
        
        $message = (locale appveyor_upload_tests_file) -f $outputFile, $target
        
        $this.logger.warning($message)
        
        if ($this.config.whatIf) { return }
        (New-Object Net.WebClient).uploadFile($target, $outputFile)
    }
    
    [Void]throwOnFail([Int]$failedCount)
    {
        if (!$failedCount) { return }
        
        $message = (locale appveyor_failed_tests_count) -f $failedCount
        
        throw $message
    }
    
}