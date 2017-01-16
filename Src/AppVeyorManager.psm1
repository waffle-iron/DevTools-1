#$env:CI = $true
#$env:APPVEYOR_BUILD_FOLDER = 'D:\User\Development\OpenSource\Current\Powershell\DevTools'


class AppVeyorManager
{
    [String]$apiLink = 'https://ci.appveyor.com/api/testresults/nunit/{0}'
    [String]$pesterFileTemplate = '{0}\{1}-{2}.NUnit.xml'
    [HashTable]$devTools = $global:devTools
    [String]$apiKey = $env:psGalleryKey
    [String]$stagingPath = $env:TEMP
    [String]$projectsPath
    
    AppVeyorManager()
    {
        $this.projectsPath = (get-item $env:APPVEYOR_BUILD_FOLDER).parent.FullName
    }
    
    [HashTable]getConfig()
    {
        return @{
            apiKey = $this.apiKey
            projectsPath = $this.projectsPath
            environment = $this.environment
        }
    }
    
    [Void]message($message, $category)
    {
        Add-AppveyorMessage $message -Category $category
    }
    
    [Void]pushArtifact($provision, $version)
    {
        $destination = '{0}\{1}-{2}.zip' -f $this.stagingPath, $provision.projectName, $version
        
        Compress-Archive -Path $provision.project.fullName "$destination" -Force -Verbose
        Push-AppveyorArtifact -Path $destination -DeploymentName $provision.projectName -Verbose
    }
    
    [Void]uploadTestsFile($provision, $pesterConfig)
    {
        $target = $this.apiLink -f $env:APPVEYOR_JOB_ID
        
        $message = "{0}Uploading {1} to {2}" -f $provision.cr, $pesterConfig.outputFile, $target
        
        $provision.warning($message)
        
        (New-Object Net.WebClient).UploadFile($target, $pesterConfig.outputFile)
    }
    
    [HashTable]getPesterDefaultConfig($provision, $moduleVersion)
    {
        return @{
            path = $provision.tests
            outputFormat = 'NUnitXml'
            outputFile = $this.pesterFileTemplate -f (
                $env:temp,
                $provision.projectName,
                $moduleVersion
            )
            passThru = $true
        }
    }
    
    [Void]throwOnFail($provision, [Int]$failedCount)
    {
        if (!$failedCount) { return }
        
        $message = '{0}Failed tests count : {1}' -f ($provision.cr, $failedCount)
        $provision.error($message)
        throw $message
    }
}