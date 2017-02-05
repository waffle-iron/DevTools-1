    [String]$entryPoint = '{0}\{1}\Tests\PesterEntryPoint'

        $this.repository = $this.project.parent.fullName
        
        $this.entryPoint = $this.entryPoint -f $this.repository, $this.projectName

    

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

























