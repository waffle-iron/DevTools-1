using module DevTools

Set-StrictMode -Version latest

. ('{0}\SharedFixtures' -f ([IO.FileInfo]$PSCommandPath).Directory)

$serviceLocator = [DevTools.ServiceLocator]::getInstance()

$testSuite = $serviceLocator.get('TestSuiteHelper')
$appVeyorService = $serviceLocator.get('AppVeyorService')

Describe 'Basic API Tests' {
    
    BeforeAll {
        $pesterShared.mocks.addAppveyorMessage.invoke()
        $pesterShared.mocks.__writeHost.invoke()
    }
    
    Context 'Misc' {
        It 'Should skip AnalyzeScript' {
            $testSuite.analyze = $false
            $testSuite.AnalyzeScript($null) | Should Be $null
        }
        
        It 'Should run AnalyzeScript and fail' {
            $testSuite.analyze = $true
            $testSuite.AnalyzeScript(@{ path = 'Tests\DebugEntry*' })
        }
        
        $testSuite.config.whatIf = $true
        
        It 'Should skip pester coverage' {
            $testSuite.coverage = $false
            { $testSuite.invokePester($testSuite.getPesterDefaultConfig(@())) } | Should Not Throw
        }
        
        It 'Should run pester coverage' {
            $testSuite.coverage = $true
            
            $coverageSourceCode = (
                @{ path = 'Src\*' }
            )
            { $testSuite.invokePester($testSuite.getPesterDefaultConfig($coverageSourceCode)) } |
            Should Not Throw
        }
        
        It 'Should throw appVeyorService.throwOnFail' {
            { $appVeyorService.throwOnFail($true) } | Should Throw
        }
        
        $testSuite.config.whatIf = $false
    }
}