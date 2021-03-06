﻿Set-StrictMode -Version latest

. ('{0}\SharedFixtures' -f ([IO.FileInfo]$PSCommandPath).Directory)

Describe 'Console Parameters' {
    
    BeforeAll {
        
        if (-not $ENV:APPVEYOR) { $ENV:APPVEYOR = $true }
        
        $pesterShared.mocks.addAppveyorMessage.invoke()
        $pesterShared.mocks.__writeHost.invoke()
    }
    
    AfterAll {
        $pesterShared.stateRestore.invoke()
        Set-Location $pesterShared.state.PWD
    }
    
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
        
        It 'Should Clear the staging path' {
            Use-DevTools Cleanup
            $pesterShared.result.nextLine() | Should Match 'Cleanup'
        }
    }
    
    Context 'SuperModule Workflow' {
        
        BeforeAll {
            $fs = $this.config.serviceLocator.get('FileSystemHelper')
            
            $fs.deleteItem('{0}\SuperModule' -f $this.config.modulesPath)
            $fs.deleteItem($this.config.getProjectPath('SuperModule'))
        }
        
        It 'Should generate SuperModule' {
            Use-DevTools GenerateModule SuperModule
            $pesterShared.result.nextLine() | Should Match "SuperModule 1.0.0 GenerateModule"
        }
        
        It 'Should not throw on SuperModule Install' {
            Use-DevTools Install SuperModule
            $pesterShared.result.nextLine() | Should Match 'SuperModule 1.0.0 Install'
        }
        
        It 'Should run SuperModule tests' {
            Use-DevTools Test SuperModule -WhatIf
            $pesterShared.result.nextLine() | Should Match 'SuperModule 1.0.0 Test'
        }
        
        It 'Should run Test-SuperModule' {
            $poppy = Test-SuperModule
            $poppy[0] | Should Match 'Hi, I''m SuperModule'
            $poppy[3] | Should Match 'Did you say: "Null" ?'
        }
        
        It 'Should run SuperModule by alias with argument' {
            $poppy = SuperModule Bobby
            $poppy[0] | Should Match 'Hi, I''m SuperModule'
            $poppy[3] | Should Match 'Did you say: "Bobby" ?'
        }
        
        It 'Should reload module if loaded' {
            Use-DevTools Test SuperModule -WhatIf
            $pesterShared.result.getLine(3) | Should Match '\[\+\] Reload SuperModule'
        }
        
        It 'Should increment version' {
            Use-DevTools BumpVersion SuperModule
            $pesterShared.result.getLine(2) | Should Match 'Update version to 1.0.1'
        }
        
        It 'Should set custom version' {
            Use-DevTools BumpVersion SuperModule -CustomVersion 1.0.0
            $pesterShared.result.getLine(2) | Should Match 'Update version to 1.0.0'
        }
        
        function global:Publish-Module { }
        
        It 'Should publish to PS Gallery' {
            Use-DevTools Publish SuperModule
            $pesterShared.result.nextLine() | Should Match 'SuperModule 1.0.0 Publish'
            $pesterShared.result.nextLine() | Should Match 'Publish the module to Powershell Gallery'
        }
        
        It 'Should deploy to PS Gallery' {
            Use-DevTools Deploy SuperModule -WhatIf
            $pesterShared.result.nextLine() | Should Match 'SuperModule 1.0.0 Deploy'
            $pesterShared.result.nextLine() | Should Match 'Update version to 1.0.1'
            $pesterShared.result.nextLine() | Should Match 'Stage bundle'
            $pesterShared.result.getLine(7) | Should Match 'Publish the module to Powershell Gallery'
            $pesterShared.result.getLine(8) | Should Match 'Using bundle'
            $pesterShared.result.getLine(9) | Should Match 'This could take some time!'
        }
        
        Remove-Item function:Publish-Module
        
        
        It 'Should copyToCurrentUserModules' {
            Set-Location ..
            Use-DevTools SuperModule copyToCurrentUserModules
            $pesterShared.result.nextLine() | Should Match 'SuperModule 1.0.1 CopyToCurrentUserModules'
            Set-Location .\SuperModule
        }
        
        AfterAll {
            It 'Should uninstall SuperModule' {
                Use-DevTools Uninstall SuperModule
                $pesterShared.result.nextLine() | Should Match 'SuperModule 1.0.1 Uninstall'
            }
        }
    }
}
