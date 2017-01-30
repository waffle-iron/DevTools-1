using namespace System.IO.Compression

Set-StrictMode -Version latest

class ModuleManager {
    [Boolean]$verbose = $false
    [Boolean]$useCache = $true
    
    [String]$uri = 'https://github.com/g8tguy/DevTools/archive/master.zip'
    [String]$slug = 'BoilerplateModule'
    
    [String]$projectName
    [String]$stagingPath
    
    [Object]$devTools
    
    [HashTable]$replaceQueue = @{ }
    
    [Array]$files = (
        'Tests\DebugEntryPoint.ps1',
        'Tests\Unit\Unit.Tests.ps1',
        'appveyor.yml',
        'Module.psproj',
        'README.md',
        'Module.psd1',
        'Module.psm1'
        
    )
    
    [Void]extractBoilerplateModule($inputFile, $outputFolder)
    {
        $archive = [ZipFile]::OpenRead($inputFile)
        
        foreach ($entry in $archive.Entries)
        {
            if ($entry.FullName -match $this.slug)
            {
                $outputFile = Join-Path $outputFolder `
                ($entry.FullName -replace ('^.*?{0}' -f $this.slug), '')
                
                $this.devTools.debug('Extract {0}' -f $outputFile)
                
                try
                {
                    [ZipFileExtensions]::ExtractToFile($entry, $outputFile, $true)
                } catch
                {
                    New-Item -Force $outputFile -ItemType directory
                }
            }
        }
        $archive.Dispose()
    }
    
    [void]prepareReplaceQueue()
    {
        $this.replaceQueue += @{
            ModuleName = $this.projectName
            NewGuid = [guid]::newGuid()
        } + $this.devTools.userSettings.userInfo
    }
    
    [void]copyToModulePath($extractionDirectory)
    {
        
        $log = robocopy $extractionDirectory $this.devTools.modulePath `
                        /xc /xn /xo /E /NJS /NS /NC /NP /NJH
        
        $log = $log |
        Where-Object { $_ -ne '' } | ForEach-Object{ 'Copy {0}' -f $_.trim() } | out-string
        $this.devTools.debug($log)
    }
    
    [Void]create()
    {
        $this.devTools.warning('Generate {0} module' -f $this.projectName)
        
        $isValidName = ($this.projectName -match '^[\.\w\d_-]+$')
        
        [IO.FileInfo]$repositoryArchive = '{0}\master.zip' -f $this.stagingPath
        $extractionDirectory = '{0}\{1}' -f $this.stagingPath, $this.slug
        
        $this.devTools.warning('Download {0}' -f $this.uri)
        
        if (-not $this.useCache)
        {
            Invoke-WebRequest -Uri $this.uri -OutFile $repositoryArchive -Verbose:$this.verbose
        }
        
        $this.devTools.warning('Extract to {0}' -f $extractionDirectory)
        
        if (-not $repositoryArchive.Exists) { throw 'Can''t find {0}' -f $repositoryArchive }
        
        $this.extractBoilerplateModule($repositoryArchive, $extractionDirectory)
        
        $this.devTools.warning('Process Data')
        
        $this.prepareReplaceQueue()
        
        
        foreach ($file in $this.files)
        {
            [IO.FileInfo]$file = '{0}\{1}' -f $extractionDirectory, $file
            
            $this.devTools.debug('Process {0}' -f $file)
            
            $this.updateContent($file)
            $this.updateFile($file)
        }
        
        $this.devTools.warning('Copy to {0}' -f $this.devTools.modulePath)
        $this.copyToModulePath($extractionDirectory)
        
        $this.devTools.remove($extractionDirectory)
        
        if (-not $this.useCache)
        {
            $this.devTools.remove($repositoryArchive)
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
        if ($file.extension -match '(psd|psm|psproj)')
        {
            [IO.FileInfo]$newName = $file -replace '\bModule', $this.projectName
            $file.moveTo($newName)
        }
    }
}