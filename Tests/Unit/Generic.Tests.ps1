#Set-StrictMode -Version latest
#
##Use-DevTools Install NewModule
##Use-DevTools CopyToCurrentUserModules NewModule
##Use-DevTools Uninstall NewModule
#
#$location = $PWD
#
##Use-DevTools GenerateProject NewMod
#
#Set-Location ..
#
##Use-DevTools NewMod GenerateProject
#
##Set-Location $location


Set-StrictMode -Version latest

. ('{0}\SharedFixtures' -f ([IO.FileInfo]$PSCommandPath).Directory)

Describe 'Console Parameters' {
    
    BeforeAll {
        $pesterShared.mocks.__writeHost.invoke()
    }
    
    AfterAll { Set-Location $pesterShared.state.PWD }
    
    Context 'Inside Module Directory' {
        
        AfterAll {
            It 'Should throw oninstalling already installed module' {
                { Use-DevTools Install } | Should Throw
            }
        }
        
        Use-DevTools
        
        It 'Should load module on first run' {
            $pesterShared.result.nextLine() | Should Match 'First Run: Loading DevTools'
        }
        
        It 'Should start tests with no arguments ' {
            $pesterShared.result.nextLine() | Should Match 'Test'
        }
        
        It 'Should uninstall module' {
            Use-DevTools uninstall
            $pesterShared.result.nextLine() | Should Match 'Uninstall'
        }
        
        It 'Should create junction link' {
            Use-DevTools install
            $pesterShared.result.getLine(2) | Should Match 'Junction created'
        }
        
    }
}
