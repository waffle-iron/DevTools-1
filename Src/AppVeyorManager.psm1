﻿using module .\ProvisionManager.psm1

$env:CI = $true
$env:APPVEYOR_BUILD_FOLDER = 'D:\User\Development\OpenSource\Current\Powershell\DevTools'

class AppVeyorManager
{
    [String]$environment = 'AppVeyor'
    [String]$apiKey = $env:psGalleryKey
    [String]$stagingPath = $env:TEMP
    [String]$projectsPath = $env:APPVEYOR_BUILD_FOLDER
    
    AppVeyorManager()
    {
        $this.projectsPath = (get-item $this.projectsPath).parent.FullName
    }
    
    [HashTable]getConfig()
    {
        return @{
            apiKey = $this.apiKey
            projectsPath = $this.projectsPath
            environment = $this.environment
        }
    }
    
    [Void]pushArtifact([ProvisionManager]$provision, $version)
    {
        $destination = '{0}\{1}-{2}.zip' -f $this.stagingPath, $provision.projectName, $version
        
        Compress-Archive -Path $provision.project.fullName "$destination" -Force -Verbose
        Push-AppveyorArtifact -Path $destination -DeploymentName $provision.projectName -Verbose
    }
}