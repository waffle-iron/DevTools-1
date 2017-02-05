using module ..\CommonInterfaces.psm1

Set-StrictMode -Version latest

class FileSystemHelper: IHelper
{
    [String]escapePath([String]$path) { return '"{0}"' -f $path }
    
    [String]createJunctionLink([String]$source, [String]$destination)
    {
        return cmd /C mklink /J $this.escapePath($destination) $this.escapePath($source) 2>&1
    }
    
    [Object]deleteItem([String]$item)
    {
        Try
        {
            $result = Remove-Item -Path $item -Recurse -Force -ErrorAction Stop -Verbose 4>&1
        } Catch
        {
            $result = $_.exception.message
        }
        return $result
    }
    
    [Object]synchronizeDirectory([String]$source, [String]$destination)
    {
        return xcopy $this.escapePath($source) $this.escapePath($destination) /Isdy
    }
}