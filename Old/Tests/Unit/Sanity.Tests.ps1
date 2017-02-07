
    Context 'AppVeyor Environment [Self Test]' {
        
        BeforeAll {
            if (-not $devTools.ci)
            {
                $env:PLATFORM = 'AppVeyor'
                $env:CI = $true
                $env:APPVEYOR_BUILD_FOLDER = $devTools.modulePath
            }
        }
        
        AfterAll { $pesterShared.stateRestore.invoke() }
        
        InModuleScope AppVeyorManager {
            
            
            Function Push-AppveyorArtifact { }
            
            InModuleScope AppVeyorAppender {
                Function Add-AppveyorMessage { }
                Mock Add-AppveyorMessage -MockWith { }
            }
            
            Mock Push-AppveyorArtifact -MockWith { }
            
            dt Install
            
            It 'Calls Add-AppveyorMessage' {
                Assert-MockCalled -ModuleName AppVeyorAppender Add-AppveyorMessage -Scope Context
            }
            
            It 'Calls Push-AppveyorArtifact on a "Tag" branch' {
                $env:APPVEYOR_REPO_TAG = $true
                dt Build
                Assert-MockCalled Push-AppveyorArtifact -Scope It;
            }
            
            It 'Should not call Push-AppveyorArtifact on non "tag" branch' {
                $env:APPVEYOR_REPO_TAG = $false
                dt Build
                Assert-MockCalled Push-AppveyorArtifact -Times 0 -Scope It;
            }
        }
    }
    
        Context  'Local Environment [Self Test]' {
            
            AfterAll { $pesterShared.stateRestore.invoke() }
            
            BeforeAll {
                $env:CI = $null

                
                [IO.FileInfo]$file = "$env:USERPROFILE\dev_tools_config.psd1"
                
                if ($env:APPVEYOR -and $file.exists -eq $false)
                {
                    It '$appVeyor should be oftype AppVeyorManager' {
                        $appVeyor | Should Be 'AppVeyorManager'
                    }
                    
                    $content | Set-Content $file
                } else
                {
                    It '$appVeyor should be $null' {
                        $appVeyor | Should Be $null
                    }
                }
            }
            
            $pesterShared.result.clear()
            
            Use-DevTools Install
            
            It 'Action should be "Install"' {
                $pesterShared.result.nextLine() | Should Match 'Install'
            }
            
            It 'Should be already installed' {
                $pesterShared.result.nextLine() | Should Be 'DevTools already installed.'
            }
            
            It 'Build should throw' {
                $env:APPVEYOR_REPO_TAG = $true
                { dt Build } | Should throw
            }
        }
}