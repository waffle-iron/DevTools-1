using namespace System.Diagnostics

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
    [String]$cr = [Environment]::NewLine
    
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
    [Void]error($text) { Write-Host $text -ForegroundColor Red }
    
    [Void]processDependencies([Scriptblock]$callback)
    {
        $this.dependencies.ForEach{
            if ($_.deploy) { $callback.invoke() }
        }
    }
    
    [Void]cleanup()
    {
        $this.processDependencies({
                
                $this.info('Cleaning : {0}\{1}' -f ($this.modules, $_.name))
                Try
                {
                    remove-item -ErrorAction Continue -Recurse -Force `
                    ('{0}\{1}' -f $this.modules, $_.name)
                } Catch
                {
                    $this.warning($this.cr + $_.Exception.Message)
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
                $this.warning($this.cr + $output)
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
       
        $this.warning('{0}Updating version to : {1}' -f ([Environment]::NewLine, $nextVersion))
        
        $version.apply($nextVersion)
        $version.updateBadge($nextVersion, $this.readme, $this.projectName)
    }
    
    [Void]publish()
    {
        $config = Import-PowerShellDataFile $env:USERPROFILE\dev_tools_config.psd1
        $apiKey = $config.apiKey
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
        
        if ([Boolean]$output) { $this.warning([Environment]::NewLine + $output) }
        if ([Boolean]$error) { $this.error([Environment]::NewLine + $error) }
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