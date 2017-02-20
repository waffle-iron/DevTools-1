using module ..\CommonInterfaces.psm1

Set-StrictMode -Version latest

enum ItemType {
    File
    Folder
    Object
    String
}

class CacheHelper: IHelper
{
    [Object]$fileSystemHelper
    
    [IO.DirectoryInfo]$object
    [IO.DirectoryInfo]$folder
    [IO.DirectoryInfo]$file
    [IO.FileInfo]$string
    
    [Void]setState()
    {
        $cachePath = '{0}\.devtools' -f $this.config.modulePath
        
        $this.object = '{0}\objects' -f $cachePath
        $this.folder = '{0}\folders' -f $cachePath
        $this.file = '{0}\files' -f $cachePath
        $this.string = '{0}\cache.json' -f $cachePath
    }
    
    [Void]persist($key, [Object]$item) { $this.persist($key, $item, [ItemType]::Object) }
    [Void]persist($key, [String]$item) { $this.persist($key, $item, [ItemType]::String) }
    [Void]persist($key, [IO.FileInfo]$item) { throw }
    [Void]persist($key, [IO.DirectoryInfo]$item) { throw }
    
    [Void]persist($key, $item, $itemType)
    {
        $cachePath = $this.validatePath($itemType)
        
        switch ($itemType)
        {
            ([ItemType]::Object)
            {
                $json = $item | ConvertTo-Json -Depth 5
                $json | Set-Content ('{0}\{1}.json' -f $cachePath, $key)
            }
            ([ItemType]::String)
            {
                [PSCustomObject]$cacheObject = Get-Content $cachePath -Force | ConvertFrom-Json
                
                if (-not $cacheObject) { $cacheObject = New-Object PSCustomObject }
                
                $cacheObject | Add-Member -Name $key -Value $item -MemberType NoteProperty -Force
                $cacheObject | ConvertTo-Json -Depth 5 | Set-Content $cachePath
            }
        }
    }
    
    [String]validatePath($itemType)
    {
        $cachePath = $this.$itemType
        
        [IO.DirectoryInfo]$cacheRoot = [IO.Path]::GetDirectoryName($cachePath)
        
        if (-not $cacheRoot.exists)
        {
            $cacheRoot.create()
            $cacheRoot.attributes = [IO.FileAttributes]::Hidden
        }
        
        if (-not $cachePath.exists) { $cachePath.create() }
        return $cachePath
    }
    
    [Object]get($key, $type)
    {
        
        $result = switch ($type)
        {
            ([String])
            {
                [PSCustomObject]$cacheObject = Get-Content $this.string -Force | ConvertFrom-Json
                Get-Property $cacheObject $key
            }
            ([Object])
            {
                [IO.FileInfo]$cachedObject = '{0}\{1}.json' -f $this.object, $key
                if (-not $cachedObject.Exists) { $null; break }
                Get-Content $cachedObject -Force | ConvertFrom-Json
            }
        }
        
        return $result
    }
}