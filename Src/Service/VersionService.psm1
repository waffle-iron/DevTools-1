using module ..\CommonInterfaces.psm1
using module ..\GenericTypes.psm1

Set-StrictMode -Version latest

class VersionService: IService
{

    [Version]$version = '0.0.0'
    [String]$regex = "ModuleVersion\s=\s'(?<version>.+)'"

    [String]next() { return $this.next($this.config.versionType) }

    [String]next([VersionComponent]$incr)
    {

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

#Write-Host($config.version)
#Write-Host($config.version.next())
#$config.version.updateManifest($config.version.next())
