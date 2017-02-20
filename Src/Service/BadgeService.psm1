using module ..\CommonInterfaces.psm1

Set-StrictMode -Version latest

class BadgeService: IService
{
    [Boolean]$useCache = $true
    
    [String]$badgesPath = '{0}\Docs\Badges'
    
    [String]$psGalleryURI = 'https://www.powershellgallery.com/packages'
    [String]$shieldsAPI = 'https://img.shields.io/badge'
    
    [Void]updateBadges()
    {
        $this.psGalleryURI = '{0}/{1}' -f $this.psGalleryURI, $this.config.moduleName
        $this.badgesPath = $this.badgesPath -f $this.config.modulePath
        
        $cacheHelper = $this.config.serviceLocator.get('CacheHelper')
        
        $readme = Get-Content $this.config.readmeFile
        
        $readme = $this.updateCoverageBadge($readme, $this.getCoverageMeta($cacheHelper))
        
        $readme = $this.updateDownloadsCountBadge($readme, $this.getDownloadsCount())
        
        $update = $this.getBadge('PSGallery', 'Powershell Gallery', $this.config.version)
        $readme = $this.updatePSGalleryBadge($readme, $update)
        
        $readme.trim() | Set-Content $this.config.readmeFile
    }
    
    [Object]updateCoverageBadge($readme, $meta)
    {
        if (-not $meta.isChanged) { return $readme }
        
        [Regex]$svg = 'Coverage/{0}.svg'
        
        return ($readme -replace ($svg -f '(\d+.*)'), ($svg -f $meta.percentage))
        
        return $readme
        
    }
    
    [HashTable]getCoverageMeta($cacheHelper)
    {
        $codeCoverage = Get-Property $cacheHelper.get('pester', [Object]) codeCoverage
        
        $percentage = 0
        
        if ($null -ne $codeCoverage)
        {
            $hit, $miss = $codeCoverage.hitCommands.length, $codeCoverage.missedCommands.length
            $percentage = [Math]::Round(($hit / ($hit + $miss)) * 100, 0)
        }
        
        $color = switch ($percentage)
        {
            { $_ -lt 50 } { "red"; break }
            { $_ -lt 50 } { "yellow"; break }
            default { 'green' }
        }
        
        $meta = @{
            isChanged = $this.getBadge('Coverage', 'Coverage', "$percentage%25", $color)
            uri = '{0}/Coverage-{1}%25-{2}.png' -f $this.shieldsAPI, $percentage, $color
            percentage = $percentage
        }
        return $meta
    }
    
    [String]getDownloadsCount()
    {
        $this.logger.warning("Get downloads count from powershell gallery")
        
        $modulePage = $this.download($this.psGalleryURI)
        
        if ($modulePage -isnot [Exception])
        {
            if ($modulePage -match 'stat-number">(?<downloads>[\d,\s]*)</p>')
            {
                return $matches['downloads']
            }
        }
        
        return $null
    }
    
    [Object]updateDownloadsCountBadge($readme, [Int]$downloadsCount)
    {
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
    
    [Boolean]getBadge($type, $title, $caption)
    {
        return $this.getBadge($type, $title, $caption, 'green')
    }
    
    [Boolean]getBadge($type, $caption) { return $this.getBadge($type, $type, $caption, 'green') }
    
    [Boolean]getBadge($type, $title, $caption, $color)
    {
        $update = $false
        
        
        $escapedName = $caption -replace '%25', ''
        
        [IO.FileInfo]$outFile = '{0}\{1}\{2}.svg' -f $this.badgesPath, $type, $escapedName
        
        if ($outFile.Exists)
        {
            $this.logger.information("The $type badge is up to date")
        } else
        {
            $uri = '{0}/{1}-{2}-{3}.svg' -f $this.shieldsAPI, $title, $caption, $color
            
            $this.logger.warning("Download $type badge")
            
            if (-not $this.download($uri, $outFile))
            {
                $update = $true
                Remove-Item -Exclude "$escapedName.svg" `
                ('{0}\{1}\*' -f $this.badgesPath, $type)
            }
        }
        return $update
    }
    
    [PSObject]download($uri) { return $this.download($uri, $null) }
    
    [PSObject]download($uri, $outFile)
    {
        try
        {
            $data = Invoke-WebRequest -Uri $uri -OutFile $outFile `
                                      -Verbose:$this.config.verbose
        } catch
        {
            $data = $_.exception
            $this.logger.error($_.exception.message)
        }
        
        return $data
    }
}