using module ..\CommonInterfaces.psm1
using module ..\GenericTypes.psm1

Set-StrictMode -Version latest

class VersionService: IService
{
    [Version]$defaultVersion = '1.0.0'
    
    [VersionComponent]$versionType
    
    [Version]$customVersion = $null
    
    [Version]$version = $this.defaultVersion
    
    [String]$regex = "ModuleVersion\s=\s'(?<version>.+)'"
    
    [Void]bind($boundParameters)
    {
        $this.version = $this.defaultVersion
        $this.versionType = Get-Property $boundParameters VersionType ([VersionComponent]::Build)
        $this.customVersion = Get-Property $boundParameters CustomVersion
    }
    
    [Void]applyNext()
    {
        $nextVersion = $this.next()
        $this.logger.warning('Update version to {0}' -f $nextVersion)
        $this.updateManifest($nextVersion)
    }
    
    [String]next() { return $this.next($this.versionType) }
    
    [String]next([VersionComponent]$incr)
    {
        if ($this.customVersion) { return $this.customVersion }
        
        $template = @{
            [VersionComponent]::Major = $this.version.Major
            [VersionComponent]::Minor = $this.version.Minor
            [VersionComponent]::Build = $this.version.Build
        }
        
        $template.item($incr) += $true
        
        return '{2}.{1}.{0}' -f ([Array]$template.values)
    }
    
    [Void]updateManifest($nextVersion)
    {
        $psd = $this.config.manifestFile
        $content = Get-Content $psd | Out-String
        
        $result = $content -replace $this.regex, "ModuleVersion = '$nextVersion'"
        $result.trim() | Set-Content $psd
    }
    
    [String]ToString() { return $this.version }
}
