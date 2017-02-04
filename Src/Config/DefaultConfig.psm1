using module .\IConfig.psm1

class DefaultConfig: IConfig
{
    DefaultConfig()
    {
        $this.userSettings = Import-PowerShellDataFile ('{0}\.devtools' -f $ENV:USERPROFILE)
    }
    
    [Void]validateCurrentLocation()
    {
        $this.currentDirectoryName = ([IO.DirectoryInfo]$pwd.path).name
        $this.isInProject = Test-Path ('{0}\{1}.psd1' -f $pwd, $this.currentDirectoryName)
    }
    
    [Array]getProjects()
    {
        return (Get-ChildItem -Directory $this.userSettings.projectsPath).forEach{ $_.name }
    }
}