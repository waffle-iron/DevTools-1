Set-StrictMode -Version latest


class ProvisionManager
{
    [IO.DirectoryInfo]$project
    [Object]$devTools
    [String]$entryPoint = '{0}\{1}\Tests\PesterEntryPoint'
    [String]$modulesPath
    [String]$repository
    [String]$projectName
    [Array]$dependencies
    
    [String]$readme = '{0}\README.md'
    
    ProvisionManager([HashTable]$data)
    {
        $this.devTools = $data.config
        $this.projectName = $data.project
        
        $this.modulesPath = $this.devTools.modulesPath
        
        $this.project = get-item $this.devTools.getProjectPath($this.projectName)
        
        if (!$this.project) { return }
        
        $this.repository = $this.project.parent.fullName
        
        $this.entryPoint = $this.entryPoint -f $this.repository, $this.projectName
        
        $this.readme = $this.readme -f $this.project.FullName
        
        $this.loadDependencies()
    }
    
    
    [Void]loadDependencies()
    {
        $this.dependencies = (@{ deploy = $true; name = $this.projectName })
        
        $this.dependencies += Get-Property $this.devTools.moduleSettings.PrivateData `
                                           DevTools.Dependencies
    }
    
    [Void]processDependencies([Scriptblock]$callback)
    {
        $this.dependencies.where({ $_ -ne $null }).forEach{ if ($_.deploy) { $callback.invoke() } }
    }
    

    
    [Void]cleanup()
    {
        $this.processDependencies({
                $this.devTools.info('Cleaning : {0}\{1}' -f ($this.modulesPath, $_.name))
                Try
                {
                    remove-item -ErrorAction Continue -Recurse -Force `
                    ('{0}\{1}' -f $this.modulesPath, $_.name)
                } Catch
                {
                    $this.devTools.warning($_.Exception.Message)
                }
                
            })
        break
    }
    
    [Void]install()
    {
        $mask = '"{0}\{1}"'
        
        $this.processDependencies({
                $destination = $mask -f $this.modulesPath, $_.name
                $source = $mask -f $this.repository, $_.name
                $output = cmd /C mklink /J $destination $source
                if ($output -eq $null)
                {
                    $this.devTools.warning("$($_.name) already installed.")
                    return
                }
                $this.devTools.warning($output)
            })
    }
    
    [Void]copy()
    {
        $mask = '"{0}\{1}"'
        
        $this.processDependencies({
                $destination = $mask -f $this.modulesPath, $_.name
                $source = $mask -f $this.repository, $_.name
                
                $output = xcopy $source $destination /Isdy
                $this.devTools.warning(($output | Out-String))
            })
    }
    
    [Void]bumpVersion($version, $nextVersion)
    {
        $message = '{0}Updating version to : {1}' -f ([Environment]::NewLine, $nextVersion)
        $this.devTools.warning($message)
        
        $version.apply($nextVersion)
        $version.updateBadge($nextVersion, $this.readme, $this.projectName)
    }
    
    [Void]publish()
    {
        if ($this.devTools.whatIf) { return }
        
        $apiKey = $this.devTools.userSettings.psGalleryApiKey
        Publish-Module -Verbose -Name $this.project.FullName -NuGetApiKey $apiKey
    }
    
    [String]bundle()
    {
        $dt = $this.devTools
        
        $bundleId = [guid]::newGuid()
        
        $dt.warning('Staging bundle {0}' -f $bundleId)
        
        foreach ($file in -split $dt.moduleSettings.fileList)
        {
            [IO.FileInfo]$fileInfo = '{0}\{1}' -f $dt.modulePath, $file
            
            $destination = '{0}\{1}\{2}' -f $dt.stagingPath, $bundleId, $file
            
            if ($fileInfo.exists -or $fileInfo.Attributes -eq [IO.FileAttributes]::Directory)
            {
                Copy-Item $fileInfo $destination -recurse
            }
        }
        
        return ('{0}\{1}' -f $dt.stagingPath, $bundleId)
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
        
        if ([Boolean]$output) { $this.devTools.warning([Environment]::NewLine + $output) }
        if ([Boolean]$error) { $this.devTools.error([Environment]::NewLine + $error) }
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

























