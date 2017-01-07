using namespace System.Diagnostics

using module .\Types.psm1


class ProvisionManager
{
    [IO.DirectoryInfo]$project
    [Object]$config
    [String]$psd = '{0}\{1}\{1}.psd1'
    [String]$entryPoint = '{0}\{1}\Tests\EntyPoint.ps1'
    [String]$tests
    [String]$modules
    [String]$repository
    [String]$projectName
    [Array]$dependencies
    
    [String]$readme = '{0}\README.md'
    
    ProvisionManager([HashTable]$data)
    {
        $this.config = $data.config
        $this.projectName = $data.project
        
        $this.modules = $this.config.modules
        
        $this.project = get-item $this.config.getProjectPath($this.projectName)
        
        if (!$this.project) { return }
        
        $this.repository = $this.project.parent.fullName
        
        $this.psd = $this.psd -f $this.repository, $this.projectName
        
        $this.entryPoint = $this.entryPoint -f $this.repository, $this.projectName
        
        $this.tests = '{0}\Tests' -f $this.project.FullName
        $this.readme = $this.readme -f $this.project.FullName
        
        $this.loadDependencies()
    }
    
    [Void]loadDependencies()
    {
        $projectConfig = Import-PowerShellDataFile $this.psd
        $this.dependencies = (@{ deploy = $true; name = $this.projectName })
        $this.dependencies += $projectConfig.PrivateData.DevTools.Dependencies
    }
    
    [Void]processDependencies([Scriptblock]$callback)
    {
        $this.dependencies.ForEach{ if ($_.deploy) { $callback.invoke() } }
    }
    
    [Void]cleanup()
    {
        $this.processDependencies({
                $this.config.info('Cleaning : {0}\{1}' -f ($this.modules, $_.name))
                Try
                {
                    remove-item -ErrorAction Continue -Recurse -Force `
                    ('{0}\{1}' -f $this.modules, $_.name)
                } Catch
                {
                    $this.config.warning($_.Exception.Message)
                }
                
            })
        break
    }
    
    [Void]install()
    {
        $mask = '"{0}\{1}"'
        
        $this.processDependencies({
                $destination = $mask -f $this.modules, $_.name
                $source = $mask -f $this.repository, $_.name
                $output = cmd /C mklink /J $destination $source
                if ($output -eq $null)
                {
                    $this.config.warning("$($_.name) already installed.")
                    return
                }
                $this.config.warning($output)
            })
    }
    
    [Void]copy()
    {
        $mask = '"{0}\{1}"'
        
        $this.processDependencies({
                $destination = $mask -f $this.modules, $_.name
                $source = $mask -f $this.repository, $_.name
                
                $output = xcopy $source $destination /Isdy
                $this.config.warning(($output | Out-String))
            })
    }
    
    [Void]bumpVersion($version, $nextVersion)
    {
        $message = '{0}Updating version to : {1}' -f ([Environment]::NewLine, $nextVersion)
        $this.config.warning($message)
        
        $version.apply($nextVersion)
        $version.updateBadge($nextVersion, $this.readme, $this.projectName)
    }
    
    [Void]publish()
    {
        if ($this.config.whatIf) { return }
        
        $apiKey = $this.config.userSettings.psGalleryApiKey
        Publish-Module -Verbose -Name $this.project.FullName -NuGetApiKey $apiKey
    }
    
    [Void]gitCommand([Array]$arguments)
    {
        $ps = new-object Process
        $ps.StartInfo.Filename = 'git'
        
        $ps.startInfo.arguments = $arguments
        
        $ps.StartInfo.RedirectStandardOutput = $True
        $ps.StartInfo.RedirectStandardError = $true
        $ps.StartInfo.UseShellExecute = $false
        $ps.Start()
        $ps.WaitForExit()
        $output = $ps.StandardOutput.ReadToEnd().trim()
        $error = $ps.StandardError.ReadToEnd().trim()
        
        if ([Boolean]$output) { $this.config.warning([Environment]::NewLine + $output) }
        if ([Boolean]$error) { $this.config.error([Environment]::NewLine + $error) }
    }
    
    [Void]gitCommitVersionChange($version)
    {
        $message = 'Version Bump {0}' -f $version
        
        $this.gitCommand((
                ('-C "{0}"' -f $this.project.FullName),
                'commit  -a -m "{0}"' -f $message
            ))
    }
    
    [Void]gitTag($version)
    {
        $desciption = '{0} release {1}.' -f $this.projectName, $version
        
        $this.gitCommand((
                ('-C "{0}"' -f $this.project.FullName),
                'tag  -a -m "{0}" "{1}"' -f $desciption, $version
            ))
    }
}