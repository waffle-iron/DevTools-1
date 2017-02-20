using module ..\CommonInterfaces.psm1
using module ..\Service\AppVeyorService.psm1

Set-StrictMode -Version latest

class TestSuiteHelper: IHelper
{
    [Boolean]$coverage = $true
    [Boolean]$analyze = $true
    
    [AppVeyorService]$appVeyorService
    
    [Object]AnalyzeScript([Array]$scripts)
    {
        $dafaultSubjects = (
            @{ path = '{0}.psm1' -f $this.config.moduleName },
            @{ path = 'Src'; recurse = $true }
        )
        
        $scripts += $dafaultSubjects
        
        if (-not $this.analyze)
        {
            $this.logger.warning('Skip ScriptAnalyzer')
            return $null
        }
        
        $scriptAnalyzer = @()
        
        foreach ($script in $scripts)
        {
            $script.path = '{0}\{1}' -f $this.config.modulePath, $script.path
            $scriptAnalyzer += Invoke-ScriptAnalyzer @script
        }
        
        if ($scriptAnalyzer)
        {
            $this.logger.error('Execute ScriptAnalyzer')
            
            $this.logger.table($scriptAnalyzer)
            
            return $scriptAnalyzer | ConvertTo-Json
            
        } else
        {
            $this.logger.information('Execute ScriptAnalyzer')
        }
        return $null
    }
    
    [Void]invokePester([HashTable]$pesterConfig)
    {
        if (-not $this.coverage) { $pesterConfig.Remove('codeCoverage') }
        
        $pester = switch ($this.config.whatIf)
        {
            true { @{ failedCount = 0 } }
            false { Invoke-Pester @pesterConfig }
        }
        
        $this.config.serviceLocator.get('CacheHelper').persist('pester', $pester)
        
        if ($this.appVeyorService)
        {
            $this.appVeyorService.processPesterResults($pester, $pesterConfig)
        }
    }
    
    [HashTable]getPesterDefaultConfig($coveragePaths)
    {
        $MODULE_PATH = $this.config.currentUserModulePath
        $MODULE_NAME = $this.config.moduleName
        
        $defaultCoveragePaths = (
            @{ path = '{0}\{1}.psm1' -f $MODULE_PATH, $MODULE_NAME },
            @{ path = '{0}\Src\*' -f $MODULE_PATH }
        )
        
        foreach ($coveragePath in $coveragePaths)
        {
            $defaultCoveragePaths += @{ path = '{0}\{1}' -f $MODULE_PATH, $coveragePath.path }
        }
        
        return @{
            outputFile = '{0}\Pester.NUnit.xml' -f $this.config.stagingPath
            outputFormat = 'NUnitXml'
            passThru = $true
            codeCoverage = $defaultCoveragePaths
            script = '{0}\Tests' -f $this.config.modulePath
        }
    }
    
    [Void]reloadModule()
    {
        $moduleName = $this.config.moduleName
        if (Get-Module $moduleName)
        {
            Remove-Module $moduleName -Force
            $this.logger.warning(('Reload {0}' -f $moduleName))
        }
    }
}