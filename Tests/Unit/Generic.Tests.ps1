Set-StrictMode -Version latest

. ('{0}\SharedFixtures' -f ([IO.FileInfo]$PSCommandPath).Directory)

Describe 'Console Parameters' {
    
    InModuleScope AppVeyorAppender {
        if (-not $ENV:APPVEYOR)
        {
            $ENV:APPVEYOR = $true
            Function Add-AppveyorMessage
            {
                param
                (
                    $Message,
                    $Category
                )
            }
        }
        
        Mock -CommandName Add-AppveyorMessage `
             –ParameterFilter { $Message -notmatch 'InnerTest' } `
             -MockWith {
            Add-AppveyorMessage -Message InnerTest -Category Information
        }
    }
    
    BeforeAll {
        $pesterShared.mocks.__writeHost.invoke()
    }
    
    AfterAll { Set-Location $pesterShared.state.PWD }
    
    Context 'Inside Module Directory' {
        
        AfterAll {
            It 'Should throw on installing already installed module' {
                { Use-DevTools Install } | Should Throw
                $pesterShared.result.nextLine() | Should Match 'Install'
            }
        }
        
        Use-DevTools -Whatif
        
        It 'Should call Add-AppveyorMessage' {
            Assert-MockCalled -ModuleName AppVeyorAppender Add-AppveyorMessage -Scope Context
        }
        
        It 'Should load module on first run' {
            $pesterShared.result.nextLine() | Should Match 'First Run: Loading DevTools'
        }
        
        It 'Should start tests with no arguments ' {
            $pesterShared.result.nextLine() | Should Match 'Test'
        }
        
        It 'Should uninstall module' {
            Use-DevTools Uninstall
            $pesterShared.result.nextLine() | Should Match 'Uninstall'
        }
        
        It 'Should create junction link' {
            Use-DevTools Install
            $pesterShared.result.getLine(2) | Should Match 'Junction created'
        }
        
        It 'Should build the module' {
            Use-DevTools Build
            $pesterShared.result.nextLine() | Should Match 'Build'
        }
    }
    
    Context 'SuperModule Workflow' {
        
        It 'Should generate SuperModule' {
            Use-DevTools GenerateModule SuperModule
            $pesterShared.result.nextLine() | Should Match "SuperModule 1.0.0 GenerateModule"
        }
        
        It 'Should run SuperModule tests' {
            Use-DevTools Test SuperModule -WhatIf
            
            $pesterShared.result.nextLine() | Should Match 'SuperModule 1.0.0 Test'
        }
        
        It 'Should not throw on SuperModule Install' {
            { Use-DevTools Install SuperModule } | Should Not Throw
            $pesterShared.result.nextLine() | Should Match 'SuperModule 1.0.0 Install'
        }
        
        It 'Should copyToCurrentUserModules' {
            Set-Location ..
            { Use-DevTools SuperModule copyToCurrentUserModules } | Should Not Throw
            $pesterShared.result.nextLine() | Should Match 'SuperModule 1.0.0 CopyToCurrentUserModules'
            Set-Location .\SuperModule
        }
        
        AfterAll {
            It 'Should uninstall SuperModule' {
                { Use-DevTools Uninstall SuperModule } | Should Not Throw
                $pesterShared.result.nextLine() | Should Match 'SuperModule 1.0.0 Uninstall'
            }
        }
        
        
    }
}
