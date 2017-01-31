#Set-StrictMode -Version latest
#
#. ('{0}\Unit\SharedFixtures' -f $devTools.testsPath)
#
#Describe 'DevTools Behavioral Tests' {
#    BeforeAll {
#        
#        $writeHostMock.invoke()
#        
#        Set-Location $devTools.userSettings.projectsPath
#        
#        $projectName = 'NewProject'
#        $projectPath = $devTools.getProjectPath($projectName)
#    }
#
#    AfterAll {
#        Set-Location $state.PWD
#        $devTools.remove($projectPath)
#    }
#    
#    Context "GenerateProject $projectName" {
#        
#        It "$projectName not exist" {
#            Test-Path $projectPath | Should Be $false
#        }
#        
#        $result = powershell -NoProfile dt $projectName GenerateProject
#        
#        It "Generate $projectName module" {
#            $devTools.warning(($result | out-string))
#            $result[1] | Should Match ('{0} 1.0.0 GenerateProject' -f $projectName)
#        }
#        
#        It "$projectName directory exists" { Test-Path $projectPath | Should Be $true }
#    }
#    
#    Context "Test DevTools on $projectName" {
#
#    }
#}