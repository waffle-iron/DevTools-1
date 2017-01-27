using module ..\Enums.psm1


Set-StrictMode -Version latest


class VersionManager
{
    [Object]$devTools
    [String]$regex = "ModuleVersion\s=\s'(?<version>.+)'"
    [Version]$version
    
    VersionManager($data)
    {
        $this.devTools = $data.config
        $this.version = $this.getVersion()
    }
    
    [Version]getVersion()
    {
        return Get-Property $this devTools.moduleSettings.ModuleVersion 1.0.0
    }
    
    [String]next([VersionComponent]$incr)
    {
        $template = @{
            [VersionComponent]::Major = $this.version.Major
            [VersionComponent]::Minor = $this.version.Minor
            [VersionComponent]::Build = $this.version.Build
        }
        
        $template.Item($incr) += $true
        
        return '{2}.{1}.{0}' -f ([Array]$template.values)
    }
    
    [Void]apply($nextVersion)
    {
        $psd = $this.devTools.psdFile
        $content = Get-Content $psd | Out-String
        
        $result = $content -replace $this.regex, "ModuleVersion = '$nextVersion'"
        $result.trim() | Set-Content $psd
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