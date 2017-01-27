Set-StrictMode -Version latest

. ('{0}\Unit\SharedFixtures' -f $devTools.testsPath)

$verbose = $true

Describe 'DevTools Behavioral Tests' {
    
    BeforeAll {
        $projectName = 'Test'
        $projectPath = $devTools.getProjectPath($projectName)
        
        #Remove-Item -ErrorAction Ignore -Path $projectPath -Recurse -Verbose:$verbose
        
        #New-Item $projectPath -ItemType directory
        
        #Set-Location $devTools.userSettings.projectsPath
        
    }
    
            It 'Generate $moduleName module' {
                dt Test -GenerateProject
                $result[0] | Should Match 'Generating {0} module.' -f $projectName
    
            }
    
}


