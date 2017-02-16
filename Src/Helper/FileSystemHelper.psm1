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
            $result = Remove-Item -Path $item -Recurse -Force `
                                  -ErrorAction Stop -Verbose:$this.config.verbose 4>&1
        } Catch
        {
            $result = $_.exception.message
        }
        
        $default = 'Remove {0}' -f $item
        
        return $this.result($result, $default)
    }
    
    [Object]safeCopy([String]$source, [String]$destination)
    {
        return robocopy $source $destination /xc /xn /xo /E /NJS /NS /NC /NP /NJH
    }
    
    [Object]synchronizeDirectory([String]$source, [String]$destination)
    {
        return xcopy $this.escapePath($source) $this.escapePath($destination) /Isdy
    }
    
    [Object]result($result, $default)
    {
        if (-not $result) { $result = $default }
        return $result
    }
    
    [Object]copyItem($fileInfo, $destination)
    {
        Try
        {
            $result = Copy-Item $fileInfo $destination -Recurse `
                                -Verbose:$this.config.verbose -ErrorAction Stop 4>&1
        } Catch
        {
            $result = $_.exception.message
        }
        
        $default = 'Copy {0}{2}===> {1}' -f $fileInfo, $destination, [Environment]::NewLine
        
        return $this.result($result, $default)
    }
    
    [Object]archive($source, $destination)
    {
        Try
        {
            $result = Compress-Archive -Path $source\* $destination -Force `
                                       -Verbose:$this.config.verbose -ErrorAction Stop 4>&1
        } Catch
        {
            $result = $_.exception.message
        }
        
        $default = 'Archive {0}{2}======> {1}' -f $source, $destination, [Environment]::NewLine
        
        return $this.result($result, $default)
    }
    
}