#$env:CI = $true
#$env:APPVEYOR_BUILD_FOLDER = 'D:\User\Development\OpenSource\Current\Powershell\DevTools'


class AppVeyorManager
{
    [HashTable]$devTools = $global:devTools
    [String]$environment = 'AppVeyor'
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
        #Add-AppveyorMessage $message -Category $category
    }
    
    [Void]pushArtifact($provision, $version)
    {
        $destination = '{0}\{1}-{2}.zip' -f $this.stagingPath, $provision.projectName, $version
        
        Compress-Archive -Path $provision.project.fullName "$destination" -Force -Verbose
        Push-AppveyorArtifact -Path $destination -DeploymentName $provision.projectName -Verbose
    }
    
}