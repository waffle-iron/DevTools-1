Set-StrictMode -Version latest

. ('{0}\Unit\SharedFixtures' -f $devTools.testsPath)

Describe 'DevTools Sanity Check' {
    
    BeforeAll {
        $pesterShared.mocks.__writeHost.invoke()
        Set-Location $devTools.modulePath
    }
    
    AfterAll { Set-Location $pesterShared.state.PWD }
    
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
            
            InModuleScope ILogger {
                Function Add-AppveyorMessage { }
                Mock -ModuleName ILogger Add-AppveyorMessage -MockWith { }
                
            }
            
            Mock Push-AppveyorArtifact -MockWith { }
            
            dt Install
            
            It 'Calls Add-AppveyorMessage' {
                Assert-MockCalled -ModuleName ILogger Add-AppveyorMessage -Scope Context
            }
            
            It 'Action should be "Install"' {
                
                $pesterShared.result.nextLine() | Should Match 'Install'
            }
            
            It 'Should be already installed' {
                $pesterShared.result.nextLine() | Should Be 'DevTools already installed.'
            }
            
            $pesterShared.result.clear()
            
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
            $env:APPVEYOR_BUILD_FOLDER = $null
            
            $content = '@{
                    projectsPath = "{projectsPath}"
                    psGalleryApiKey = $null
                
                    userInfo = (
                        @{
                            gitHubSlug = $null
                            userName = $null
                            gitHubAuthToken = $null
                        }
                    )
                }' -replace '{projectsPath}', $devTools.ciProvider::projectsPath
            
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
        
        dt Install
        
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