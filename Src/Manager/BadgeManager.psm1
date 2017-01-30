using namespace System.Management.Automation

class BadgeManager {
    
    [Object]$devTools
    [Boolean]$verbose
    
    [String]$projectName
    
    [String]$stagingPath
    [String]$badgesPath = '{0}\Docs\Badges'
    [String]$readmePath
    [String]$modulePath
    
    [String]$version
    
    [Array]$requiredModules
    
    [String]$psGalleryURI = 'https://www.powershellgallery.com/packages'
    [String]$shieldsAPI = 'https://img.shields.io/badge'
    
    [void]updateBadgs()
    {
        $readme = Get-Content $this.readmePath
        
        $this.psGalleryURI = '{0}/{1}' -f $this.psGalleryURI, $this.projectName
        $this.badgesPath = $this.badgesPath -f $this.modulePath
        
        $readme = $this.updatePSGalleryDownloadsCountBadge($readme, $this.getPSGalleryDownloadsCount())
        
        $readme = $this.updatePSGalleryBadge($readme, $this.getPSGalleryBadge())
        
        $readme = $this.updateRequiredModulesBadge($readme, $this.verifyRequiredModules())

        $readme.trim() | Set-Content $this.readmePath
    }
    
    [Object]updatePSGalleryDownloadsCountBadge($readme, $downloadsCount)
    {
        if ($downloadsCount)
        {
            $this.getDownloadsCountBadge($downloadsCount)
            $readme = $readme -replace 'downloads(\d+.*)svg$', "downloads$downloadsCount.svg"
        }
        
        return $readme
    }
    
    [Object]updatePSGalleryBadge($readme, $update)
    {
        if ($update)
        {
            $readme = $readme -replace 'ps-gallery-(.*?)svg', "ps-gallery-$($this.version).svg"
            $precursor = '/packages/{0}' -f $this.projectName
            $readme = $readme -replace "$precursor/(\d.*?)$", "$precursor/$($this.version)"
        }
        return $readme
    }
    
    
    [Object]updateRequiredModulesBadge($readme, $isVerified)
    {
        return $readme -replace 'req-(\w+)', "req-$isVerified".toLower()
    }
    
    [Boolean]verifyRequiredModules()
    {
        [Boolean]$isVerified = $true
        
        $this.devTools.warning('Processing required modules')
        
        foreach ($module in $this.requiredModules)
        {
            $name = Get-Property $module ModuleName $module
            
            if ($requiredVersion = Get-Property $module RequiredVersion)
            {
                $latest = (Find-Module -Name $name).version

                $message = '"{0}" required {1}, latest {2}' -f $name, $requiredVersion, $latest
                
                $importance = switch ($latest -eq $requiredVersion)
                {
                    true{ 'warning' }
                    false{ 'error'; $isVerified = $false }
                }
                
                $this.devTools.$importance($message)
                
            } else
            {
                $this.devTools.warning('"{0}" module "RequiredVersion" is not specified' -f $name)
            }
        }
        
        return $isVerified
    }
    [String]download($uri, $outFile)
    {
        $data = $null
        
        try
        {
            $data = Invoke-WebRequest -Uri $uri -Verbose:$this.verbose -OutFile $outFile
        } catch
        {
            $this.devTools.error('404 - Can''t find {0}' -f $uri)
        }
        
        return $data
    }
    
    [String]getPSGalleryDownloadsCount()
    {
        if ($page = $this.download($this.psGalleryURI, $null))
        {
            if ($page -match 'stat-number">(?<downloads>[\d,\s]*)</p>')
            {
                return $matches['downloads']
            }
        }
        
        return $null
    }
    
    [Boolean]getPSGalleryBadge()
    {
        $update = $false
        
        $this.devTools.warning('The "Powershell Gallery" badge should be {0}' -f $this.version)
        
        [IO.FileInfo]$outFile = '{0}\ps-gallery-{1}.svg' -f $this.badgesPath, $this.version
        
        if ($outFile.Exists)
        {
            $this.devTools.warning('The "Powershell Gallery" badge up to date')
        } else
        {
            $uri = '{0}/Powershell_Gallery-{1}-green.svg' -f $this.shieldsAPI, $this.version
            
            $this.devTools.warning('Download "Powershell Gallery" badge')
            $this.download($uri, $outFile)
            $update = $true
        }
        return $update
    }
    
    [Void]getDownloadsCountBadge([String]$downloads)
    {
        $this.devTools.warning('The "Downloads" badge should be {0}' -f $downloads)
        
        [IO.FileInfo]$outFile = '{0}\downloads{1}.svg' -f $this.badgesPath, $downloads
        
        if ($outFile.Exists)
        {
            $this.devTools.warning('The "Downloads" badge is up to date')
        } else
        {
            $uri = '{0}/Downloads-{1}-green.svg' -f $this.shieldsAPI, $downloads
            
            $this.devTools.warning('Download "Downloads" badge')
            $page = $this.download($uri, $outFile)
        }
    }
}