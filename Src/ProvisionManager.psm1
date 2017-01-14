enum Action {
    Install
    CopyToCurrentUserModules
    Test
    Cleanup
    BumpVersion
    Publish
    Deploy
    Build
    Release
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
        
        
        $this.modules = ($Env:PSModulePath.Split(';') |
            Where-Object { $_ -match $this.modules }) | Select-Object -Unique
        
        $this.project = (get-item $this.root).parent
        
        $this.repository = $this.project.parent.fullName
        $this.projectName = $this.project.Name
        $this.psd = $this.psd -f $this.repository, $this.projectName
        $this.entryPoint = $this.entryPoint -f $this.repository, $this.projectName
        $this.readme = $this.readme -f $this.project.FullName
    }
    
    
    [Void]info($text) { Write-Host $text -ForegroundColor DarkGreen }
    [Void]warning($text) { Write-Host $text -ForegroundColor Yellow }
    [Void]error($text) { Write-Host $text -ForegroundColor DarkGreen }
    
    [Void]processDependencies([Scriptblock]$callback)
    {
        $this.dependencies.ForEach{
            if ($_.deploy) { $callback.invoke() }
        }
    }
    
    [Void]cleanup()
    {
        $this.processDependencies({
                
                $this.info('Cleaning:{0}\{1}' -f ($this.modules, $_.name))
                Try
                {
                    remove-item -ErrorAction Continue -Recurse -Force `
                    ('{0}\{1}' -f $this.modules, $_.name)
                } Catch
                {
                    $this.warning($_.Exception.Message)
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
                $this.info($output)
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
        $this.info('Bump version to:{0}' -f $nextVersion)
        $version.apply($nextVersion)
        $version.updateBadge($nextVersion, $this.readme, $this.projectName)
    }
    
    [Void]publish()
    {
        $config = Import-PowerShellDataFile $env:USERPROFILE\dev_tools_config.psd1
        $apiKey = $config.apiKey
        Publish-Module -Verbose -Name $this.project.FullName -NuGetApiKey $apiKey
    }
    
    [Void]gitCommitVersionChange($version)
    {
        $message = 'Bump version to {0}.' -f $version
#        $output = git -C "$($this.project.FullName)" commit -a -m "$message" 2>&1
#        $this.warning(($output | Out-String))
        

        #$output = git -C "$($this.project.FullName)" tag -a -m "$desciption" "$version" 2>&1
        $ps = new-object System.Diagnostics.Process
        $ps.StartInfo.Filename = "git"
        
        $ps.StartInfo.Arguments = (
            ('-C "{0}"' -f $this.project.FullName),
            'commit  -a -m "{0}"' -f $message
        )
        
        
        
        $ps.StartInfo.RedirectStandardOutput = $True
        $ps.StartInfo.RedirectStandardError = $true
        $ps.StartInfo.UseShellExecute = $false
        $ps.start()
        $ps.WaitForExit()
        [string]$out = $ps.StandardError.ReadToEnd();
        $z = $ps.StandardOutput.ReadToEnd();
        $this.warning(($z | Out-String).trim())
        $this.error(($out | Out-String).trim())
        
    }
    
    [Void]gitTag($version)
    {
        $desciption = '{0} release {1}.' -f $this.projectName, $version
        #$output = git -C "$($this.project.FullName)" tag -a -m "$desciption" "$version" 2>&1
        $ps = new-object System.Diagnostics.Process
        $ps.StartInfo.Filename = "git"

        $ps.StartInfo.Arguments = (
            ('-C "{0}"' -f $this.project.FullName),
            'tag  -a -m "{0}" "{1}"' -f $desciption, $version
        )
        
        
        
        $ps.StartInfo.RedirectStandardOutput = $True
        $ps.StartInfo.RedirectStandardError = $true
        $ps.StartInfo.UseShellExecute = $false
        $ps.start()
        $ps.WaitForExit()
        [string]$out = $ps.StandardError.ReadToEnd();
        
        $this.error(($out | Out-String).trim())
        
        #        Try
        #        {
        #            
        #            $aa = Start-Process -NoNewWindow -PassThru -Wait `
        #                                -FilePath git
        #            #git -C "$($this.project.FullName)" tag -a -m "$desciption" "$version"
        #        } Catch
        #        {
        #            #Write-Host($aa)
        #            #$this.warning($_)
        #        }
        
        
        #$this.warning($output)
        #Write-Host ($output|Format-List| Out-String)
    }
}




















