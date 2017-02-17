using module Logger

using module ..\CommonInterfaces.psm1

Set-StrictMode -Version latest

class ModuleGeneratorService: IService
{
    [Object]$fileSystemHelper
    
    [Array]$files
    
    ModuleGeneratorService()
    {
        $this.files = (
            'Tests\DebugEntryPoint.ps1',
            'Tests\Unit\Generic.Tests.ps1',
            'appveyor.yml',
            'Module.psproj',
            'README.md',
            'Module.psd1',
            'Module.psm1'
        )
    }
    
    [HashTable]getReplaceQueue()
    {
        return @{
            MODULE_NAME = $this.config.moduleName
            NEW_GUID = [guid]::newGuid()
        } + $this.config.userSettings.userInfo
    }
    
    [Void]processFiles($boilerplateDirectory, $replaceQueue)
    {
        foreach ($file in $this.files)
        {
            [IO.FileInfo]$file = '{0}\{1}' -f $boilerplateDirectory, $file
            
            $this.logger.debug('Processing {0}' -f $file)
            
            $this.updateContent($file, $replaceQueue)
            $this.updateFileName($file)
            
        }
    }
    
    [Void]updateContent($file, $replaceQueue)
    {
        $content = Get-Content $file | Out-String
        
        foreach ($placeHolder in $replaceQueue.GetEnumerator())
        {
            $content = $content -replace $placeHolder.name, $placeHolder.value
        }
        
        $content.trim() | Set-Content $file
    }
    
    [Void]updateFileName($file)
    {
        if ($file.extension -match '(psd|psm|psproj)')
        {
            [IO.FileInfo]$newName = $file -replace '\bModule', $this.config.moduleName
            $file.moveTo($newName)
        }
    }
    
    generate()
    {
        $fs = $this.fileSystemHelper
        $modulePath = $this.config.modulePath
        
        $src = '{0}\Assets\BoilerplateModule' -f $this.config.devToolsPath
        
        $boilerplateDirectory = '{0}\BoilerplateModule' -f $this.config.stagingPath
        
        $this.logger.list($fs.deleteItem($modulePath))
        
        $this.logger.list($fs.synchronizeDirectory($src, $boilerplateDirectory))
        
        $this.logger.warning('Prepare {0} files' -f $boilerplateDirectory)
        $this.processFiles($boilerplateDirectory, $this.getReplaceQueue())
        
        $this.logger.warning('Copy to {0}' -f $modulePath)
        
        $this.logger.list($fs.safeCopy($boilerplateDirectory, $modulePath))
        
        $this.logger.list($fs.deleteItem($boilerplateDirectory))
    }
}
