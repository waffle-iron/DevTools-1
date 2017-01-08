enum Action {
    Development
    Shortcuts
    Copy
    Cleanup
    BumpVersion
    Publish
    Deploy
}


class ProvisionManager
{
    $root
    $project
    [String]$psd = '{0}\{1}\{1}.psd1'
    [String]$entryPoint = '{0}\{1}\Tests\{1}.Test.ps1'
    [String]$modules = 'Documents'
    [String]$repository
    [String]$projectName
    [Array]$dependencies
    [String]$readme = '{0}\README.md'
    
    ProvisionManager($data)
    {
        $this.root = $data.root
        $this.modules = $Env:PSModulePath.Split(';') | Where-Object { $_ -match $this.modules }
        
        $this.project = (get-item $this.root).parent
        
        $this.repository = $this.project.parent.FullName
        $this.projectName = $this.project.Name
        $this.psd = $this.psd -f $this.repository, $this.projectName
        $this.entryPoint = $this.entryPoint -f $this.repository, $this.projectName
        $this.readme = $this.readme -f $this.project.FullName
    }
    
    [Void]report($text) { Write-Host $text -ForegroundColor DarkGreen }
    [Void]warning($text) { Write-Host $text -ForegroundColor DarkRed }
    
    [Void]processDependencies([Scriptblock]$callback)
    {
        $this.dependencies.ForEach{
            if ($_.deploy) { $callback.invoke() }
        }
    }
    
    [Void]cleanup()
    {
        $this.processDependencies({
                
                $this.report('Cleaning:{0}\{1}' -f ($this.modules, $_.name))
                Try
                {
                    remove-item -ErrorAction Continue -Recurse -Force `
                    ('{0}\{1}' -f $this.modules, $_.name)
                }
                Catch
                {
                    $this.warning($_.Exception.Message)
                }
                
            })
        break
    }
    
    [Void]shortcuts()
    {
        $mask = '"{0}\{1}"'
        
        $this.processDependencies({
                $destination = $mask -f $this.modules, $_.name
                $source = $mask -f $this.repository, $_.name
                $output = cmd /C mklink /J $destination $source
                $this.report($output)
            })
    }
    
    [Void]copy()
    {
        $mask = '"{0}\{1}"'
        
        $this.processDependencies({
                $destination = $mask -f $this.modules, $_.name
                $source = $mask -f $this.repository, $_.name
                
                $output = xcopy $source $destination /Isdy
                $this.warning(($output | Out-String))
            })
    }
    
    [Void]bumpVersion($version, $nextVersion)
    {
        $this.report('Bump version to:{0}' -f $nextVersion)
        $version.apply($nextVersion)
        $version.updateBadge($nextVersion, $this.readme, $this.projectName)
    }
    
    [Void]publish()
    {
        $config = Import-PowerShellDataFile $env:USERPROFILE\dev_tools_config.psd1
        $apiKey = $config.apiKey
        Publish-Module -Name $this.project.FullName -NuGetApiKey $apiKey
    }
}