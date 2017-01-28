Set-StrictMode -Version latest

. ('{0}\Unit\SharedFixtures' -f $devTools.testsPath)

Describe 'DevTools Behavioral Tests' {
    BeforeAll {
        $writeHostMock.invoke()
        
        Set-Location $devTools.userSettings.projectsPath
        
        $projectName = 'NewProject'
        $projectPath = $devTools.getProjectPath($projectName)
    }
    
    AfterAll {
        Set-Location $state.PWD
        Remove-Item -ErrorAction Ignore -Path $projectPath -Recurse -Verbose:$verbose
    }
    
    Context 'GenerateProject' {
        
        $result = powershell -NoProfile dt $projectName GenerateProject
        
        It "Generate $projectName module" {
            $devTools.warning(($result | out-string))
            $result[1] | Should Match ('{0} 1.0.0 GenerateProject' -f $projectName)
        }
        
    }
}