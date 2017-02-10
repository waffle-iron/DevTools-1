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
        
        Use-DevTools
        
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
    
    Context 'Common Workflow' {
        
        It 'Should generate project' {
            Use-DevTools GenerateProject TestModule
            $pesterShared.result.getLine(1) | Should Match 'GenerateProject'
        }
    }
}
