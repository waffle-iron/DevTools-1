enum VersionComponent
{
    Major
    Minor
    Build
}


class VersionManager
{
    [String]$psd
    [String]$regex = "ModuleVersion\s=\s'(?<version>.+)'"
    [String]$content
    [Version]$version
    
    VersionManager($data)
    {
        $this.psd = $data.psd
        $this.content = Get-Content $this.psd | Out-String
        $this.version = $this.getVersion()
    }
    
    [Version]getVersion()
    {
        $result = switch ($this.content -match $this.regex)
        {
            True { $matches['version'] }
            default { $false }
        }
        
        return $result
    }
    
    [String]next([VersionComponent]$incr)
    {
        $temlate = @{
            [VersionComponent]::Major = $this.version.Major
            [VersionComponent]::Minor = $this.version.Minor
            [VersionComponent]::Build = $this.version.Build
        }
        
        $temlate.Item($incr) += $true
        
        return '{2}.{1}.{0}' -f ([Array]$temlate.Values)
    }
    
    [Void]apply($nextVersion)
    {
        $result = $this.content -replace $this.regex, "ModuleVersion = '$nextVersion'"
        $result.trim() |
        Set-Content $this.psd
    }

    [Void]updateBadge($nextVersion, $readme, $projectName)
    {
        $rm = Get-Content $readme | Out-String

        $badge = 'PowerShell_Gallery-{0}-green.svg'
        $link = "/packages/$projectName/{0}"
        
        $rm = $rm -replace ($badge -f '(.+)'), ($badge -f $nextVersion)
        $rm = $rm -replace ($link -f '(.+)'), ($link -f $nextVersion)
        
        $rm.trim() | Set-Content $readme
    }
}