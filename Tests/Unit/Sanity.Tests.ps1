Set-StrictMode -Version latest

. ('{0}\Unit\SharedFixtures' -f $devTools.testsPath)

Describe 'DevTools Sanity Check' {
    BeforeAll {
        $writeHostMock.invoke()
        
        Set-Location $devTools.modulePath
    }
    
    AfterAll { Set-Location $state.PWD }
    
    Context 'AppVeyor Environment [Self Test]' {
        BeforeAll {
            if (-not $devTools.ci)
            {
                $env:PLATFORM = 'AppVeyor'
                $env:CI = $true
                $env:APPVEYOR_BUILD_FOLDER = $devTools.modulePath
            }
        }
        
        AfterAll {
            $restoreState.invoke()
        }
        
        InModuleScope 'AppVeyorManager' {
            
            Function Add-AppveyorMessage { }
            Function Push-AppveyorArtifact { }
            
            Mock Add-AppveyorMessage -MockWith { }
            Mock Push-AppveyorArtifact -MockWith { }
            
            $global:result = @()
            
            dt Install
            
            It 'Action should be "Install"' {
                $result[0] | Should Match 'Install'
                $result[1] | Should Be 'DevTools already installed.'
            }
            
            It 'Should be already installed' {
                $result[1] | Should Be 'DevTools already installed.'
            }
            
            It 'Calls Add-AppveyorMessage' {
                Assert-MockCalled Add-AppveyorMessage -Scope Context;
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
                    $appVeyor | Should be 'AppVeyorManager'
                }
                
                $content | Set-Content $file
            } else
            {
                It '$appVeyor should be $null' {
                    $appVeyor | Should be $null
                }
            }
        }
        
        AfterAll {
            $restoreState.invoke()
        }
        
        $global:result = @()
        
        dt Install
        
        It 'Action should be "Install"' {
            $result[0] | Should Match 'Install'
        }
        
        It 'Should be already installed' {
            $result[1] | Should Be 'DevTools already installed.'
        }
        
        It 'Build should throw' {
            $env:APPVEYOR_REPO_TAG = $true
            { dt Build } | Should throw
        }
    }
}