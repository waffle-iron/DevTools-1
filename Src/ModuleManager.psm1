class ModuleManager {
    
    [Object]$config
    
    [String]$moduleName
    [String]$moduleURI
    
    [HashTable]$replaceQueue = @{ }
    
    [Array]$files = (
        'Tests\Unit\Module.Tests.ps1',
        'appveyor.yml',
        'Module.psd1',
        'Module.psm1',
        'README.md'
    )
    
    [String]$demoModuleURI = '{0}\Examples\BoilerplateModule'
    
    [Void]create()
    {
        $this.demoModuleURI = $this.demoModuleURI -f (Get-Item $PSScriptRoot).parent.fullName
        $this.moduleURI = $this.config.getProjectPath($this.moduleName)
        
        $this.replaceQueue += @{
            ModuleName = $this.moduleName
            NewGuid = [guid]::newGuid()
        } + $this.config.userSettings.userInfo
        

        $output = xcopy $this.demoModuleURI $this.moduleURI /Isdy
        $this.config.warning('Generating {0} module.' -f $this.moduleName)

        foreach ($file in $this.files)
        {
            [IO.FileInfo]$file = '{0}\{1}' -f $this.moduleURI, $file
            $this.updateContent($file)
            $this.updateFile($file)
        }
    }
    
    [Void]updateContent([IO.FileInfo]$file)
    {
        $content = Get-Content $file | Out-String
        
        $this.replaceQueue.GetEnumerator().foreach{
            $content = $content -replace $_.Name, $_.Value
        }
        
        $content.trim() | Set-Content $file
    }
    
    [Void]updateFile([IO.FileInfo]$file)
    {
        if ($file.extension -match '(psd|psm)')
        {
            [IO.FileInfo]$newName = '{0}\{1}{2}' -f (
                $this.moduleURI,
                $this.moduleName,
                $file.extension
            )
            
            if ($newName.exists) { $file.delete(); return }
            
            $file.moveTo($newName)
        }
    }
}