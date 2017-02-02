using module .\IManager.psm1


Set-StrictMode -Version latest


class AppVeyorManager: IManager
{
    static [String]$projectsPath = [IO.Directory]::GetParent($env:APPVEYOR_BUILD_FOLDER)
    static [String]$apiKey = $env:psGalleryKey
    
    [String]$apiLink = 'https://ci.appveyor.com/api/testresults/nunit/{0}'
    [String]$pesterFileTemplate = '{0}\{1}-{2}.NUnit.xml'
    
    static [HashTable]getConfig()
    {
        return @{
            projectsPath = [AppVeyorManager]::projectsPath
            psGalleryApiKey = [AppVeyorManager]::apiKey
            
            userInfo = (
                @{
                    gitHubSlug = $null
                    userName = $null
                    gitHubAuthToken = $null
                }
            )
        }
    }
    
    static [Void]message($message, $category)
    {
        Add-AppveyorMessage $message -Category $category
    }
    
    [Void]pushArtifact($version)
    {
        $destination = '{0}\{1}-{2}.zip' -f (
            $this.devTools.stagingPath,
            $this.devTools.projectName,
            $version
        )
        
        $bundle = $this.devTools.provision.bundle()
        
        $this.devTools.warning('Compressing bundle {0}' -f $destination)
        
        Compress-Archive -Path $bundle\* "$destination" -Force -Verbose:$this.devTools.verbose
        
        $this.devTools.warning('Cleaning up the {0}' -f $bundle)
        
        Remove-Item -Path $bundle -Recurse -Verbose:$this.devTools.verbose
        
        $this.devTools.warning('Pushing bundle to "Appveyor" as {0}' -f $this.devTools.projectName)
        Push-AppveyorArtifact -Path $destination `
                              -DeploymentName $this.devTools.projectName `
                              -Verbose:$this.devTools.verbose
        
    }
    
    [Void]uploadTestsFile($pesterConfig)
    {
        $target = $this.apiLink -f $env:APPVEYOR_JOB_ID
        
        $message = "Uploading {0} to {1}" -f $pesterConfig.outputFile, $target
        
        $this.devTools.warning([Environment]::NewLine + $message)
        
        (New-Object Net.WebClient).UploadFile($target, $pesterConfig.outputFile)
    }
    
    [HashTable]getPesterDefaultConfig($moduleVersion)
    {
        return @{
            path = $this.devTools.testsPath
            outputFormat = 'NUnitXml'
            outputFile = $this.pesterFileTemplate -f (
                $env:temp,
                $this.devTools.projectName,
                $moduleVersion
            )
            passThru = $true
        }
    }
    
    [Void]throwOnFail([Int]$failedCount)
    {
        if (!$failedCount) { return }
        
        $message = '{0}Failed tests count : {1}' -f [Environment]::NewLine, $failedCount
        throw $message
    }
}