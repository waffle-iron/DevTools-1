using module ..\CommonInterfaces.psm1

class TestSuiteHelper: IHelper
{
    [Boolean]$coverage = $true
    [Boolean]$analyze = $true
    
    [Object]AnalyzeScript([Array]$scripts)
    {
        $dafaultSubjects = (
            @{ path = '{0}.psm1' -f $this.config.moduleName },
            @{ path = 'Src'; recurse = $true }
        )
        
        $scripts += $dafaultSubjects
        
        if (-not $this.analyze)
        {
            $this.logger.warning('[?] ScriptAnalyzer disabled.')
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
            $this.logger.error('[-] ScriptAnalyzer faild.')
            
            $this.logger.table($scriptAnalyzer)
            
            return $scriptAnalyzer | ConvertTo-Json
            
        } else
        {
            $this.logger.information('[+] ScriptAnalyzer should pass.')
        }
        return $null
    }
    
    [Void]invokePester([HashTable]$pesterConfig)
    {
        if (-not $this.coverage) { $pesterConfig.Remove('codeCoverage') }
        $pester = Invoke-Pester @pesterConfig
        
    }
    
    
    [HashTable]getPesterDefaultConfig($coveragePaths)
    {
        $MODULE_PATH = $this.config.currentUserModulePath
        $MODULE_NAME = $this.config.moduleName
        
        $defaultCoveragePaths = (
            @{ path = '{0}\{1}.psm1' -f $MODULE_PATH, $MODULE_NAME },
            @{ path = '{0}\Src\*' -f $MODULE_PATH  }
        )
        
        foreach ($coveragePath in $coveragePaths)
        {
            $defaultCoveragePaths += @{ path = '{0}\{1}' -f $MODULE_PATH, $coveragePath.path }
        }
        
        return @{
            codeCoverage = $defaultCoveragePaths
            script = '{0}\Tests\Unit\Generic.Tests.ps1' -f $this.config.modulePath
        }
    }
}