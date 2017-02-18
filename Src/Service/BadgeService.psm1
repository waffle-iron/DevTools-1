using module ..\CommonInterfaces.psm1

Set-StrictMode -Version latest

class BadgeService: IService
{
    [String]$badgesPath = '{0}\Docs\Badges'
    
    [String]$psGalleryURI = 'https://www.powershellgallery.com/packages'
    [String]$shieldsAPI = 'https://img.shields.io/badge'
    
    [Void]updateBadges()
    {
        $readme = Get-Content $this.config.readmeFile
        
        $this.psGalleryURI = '{0}/{1}' -f $this.psGalleryURI, $this.config.moduleName
        $this.badgesPath = $this.badgesPath -f $this.config.modulePath
        
        #$this.logger.list($this)
        
        $update = $this.getPSGalleryDownloadsCount()
        $readme = $this.updatePSGalleryDownloadsCountBadge($readme, $update)
        
        $update = $this.getBadge('PSGallery', $this.config.version)
        $readme = $this.updatePSGalleryBadge($readme, $true)
        
        $readme.trim() | Set-Content $this.config.readmeFile
    }
    
    [String]getPSGalleryDownloadsCount()
    {
        
        $this.logger.warning("Get downloads count from powershell gallery")
        if ($page = $this.download($this.psGalleryURI, $null))
        {
            if ($page -match 'stat-number">(?<downloads>[\d,\s]*)</p>')
            {
                return $matches['downloads']
            }
        }
        
        return $null
    }
    
    [Object]updatePSGalleryDownloadsCountBadge($readme, $downloadsCount)
    {
        if (-not $downloadsCount) { return $readme }  { }
        if (-not $this.getBadge('Downloads', $downloadsCount)) { return $readme }
        
        [Regex]$svg = 'Downloads/{0}.svg'
        
        return ($readme -replace ($svg -f '(\d+.*)'), ($svg -f $downloadsCount))
    }
    
    [Object]updatePSGalleryBadge($readme, $update)
    {
        [Regex]$svg = 'PSGallery/{0}.svg'
        [Regex]$link = "/packages/$($this.config.moduleName)/{0}"
        
        if ($update)
        {
            $readme = $readme -replace ($svg -f '(.*?)'), ($svg -f $this.config.version)
            $readme = $readme -replace ($link -f '(\d.*?)$'), ($link -f $this.config.version)
        }
        return $readme
    }
    
    [Boolean]getBadge($type, $name)
    {
        $update = $false
        
        [IO.FileInfo]$outFile = '{0}\{1}\{2}.svg' -f $this.badgesPath, $type, $name
        
        if ($outFile.Exists)
        {
            $this.logger.information("The $type badge is up to date")
        } else
        {
            $uri = '{0}/Powershell_Gallery-{1}-green.svg' -f $this.shieldsAPI, $name
            
            $this.logger.warning("Download $type badge")
            
            if (-not $this.download($uri, $outFile))
            {
                $update = $true
                Remove-Item -Exclude "$name.svg" `
                ('{0}\{1}\*' -f $this.badgesPath, $type)
            }
        }
        return $update
    }
    
    [PSObject]download($uri, $outFile)
    {
        try
        {
            $data = Invoke-WebRequest -Uri $uri -OutFile $outFile `
                                      -Verbose:$this.config.verbose
        } catch
        {
            $data = $_.exception.message
            $this.logger.error($data)
        }
        
        return $data
    }
    
}