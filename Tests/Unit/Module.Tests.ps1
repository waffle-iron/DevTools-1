# https://github.com/pester/Pester/tree/master/Functions
#using module ..\..\DevTools.psm1
using module DevTools

using module ..\..\Src\DynamicParameter.psm1

Describe "DevTools Tests" {
    BeforeAll {
        $debug = $false
        function global:Write-Host($text)
        {
            if ($debug) {
                Microsoft.PowerShell.Utility\Write-Host $text -ForegroundColor Blue
            }
            $global:result += $text
        }
    }
    
    AfterAll {
        Remove-Item function:Write-Host
    }
    
    BeforeEach { $global:result = @() }
    
    Context "DevTools" {
        
        It "Install DevTools module to the CurrenUser scope" {
            dt DevTools Install
            $result[0] | Should Match "Install"
            $result[1] | Should Be "DevTools already installed."
        }
    }
    
    Context "Test Module" {
        
        BeforeAll {
            $moduleName = "Test"
            
            $currentPath = $pwd
            
            $devTools = $global:devTools
            $testProjectPath = $devTools.getProjectPath($moduleName)
            
            Set-Location $testProjectPath
            #$a = git init
            #$a = git add .
            
            Set-Location $currentPath
            
        }
        
        AfterAll {
            dt Test Cleanup
            dt Test BumpVersion -CustomVersion 1.0.0
        }
        
        
        
        
        It "Generate $moduleName module" {
            dt -GenerateProject Test
            $result[0] | Should Match "Generating $moduleName module."

        }
        
        It "Install $moduleName module to the CurrenUser scope" {
            dt Test Install
            $result[0] | Should Match "$moduleName 1.0.0 Install"
            $result[1] | Should Match "Junction created"
            
        }
        
        It "CopyToCurrentUserModules" {
            dt Test CopyToCurrentUserModules
            $result[0] | Should Match "$moduleName 1.0.0 CopyToCurrentUserModules"
            $result[1] | Should Match "9 File\(s\) copied"
            
        }
        
        It "BumpVersion" {
            dt Test BumpVersion
            $result[0] | Should Match "$moduleName 1.0.0 BumpVersion"
            $result[1] | Should Match "Updating version to : 1.0.1"
        }
        
        It "BumpVersion Major" {
            dt Test BumpVersion Major
            $result[0] | Should Match "$moduleName 1.0.1 BumpVersion"
            $result[1] | Should Match "Updating version to : 2.0.1"
        }
        
        It "BumpVersion Custom" {
            dt Test BumpVersion -CustomVersion 3.3.3
            $result[0] | Should Match "$moduleName 2.0.1 BumpVersion"
            $result[1] | Should Match "Updating version to : 3.3.3"
        }
        
        It "Publish $moduleName" {
            dt Test Publish -WhatIf
            $result[0] | Should Match "$moduleName 3.3.3 Publish"
        }
        
        It "Deploy $moduleName" {
            dt Test Deploy -WhatIf
            $result[0] | Should Match "$moduleName 3.3.3 Deploy"
            $result[1] | Should Match "Updating version to : 3.3.4"
        }
        
        It "Build $moduleName should throw" {
            { dt Test Build -WhatIf } | Should Throw
        }
        
        It "Release $moduleName" {
           # dt Test Release -WhatIf
           # $result[0] | Should Match "$moduleName 3.3.4 Release"
        }
        

        
        It "Cleanup $moduleName module from the CurrenUser scope" {
            dt Test Cleanup
            $result[0] | Should Match "$moduleName \d.\d.\d Cleanup"
            $result[1] | Should Match "Cleaning :"

        }
        
        #        $output = powershell -NoProfile dt Test
        #        
        #        It "Testing $moduleName Module" {
        #            $output[0] | Should Match "Test 1.0.0 Test"
        #            $output[6] | Should Match "Describing Test Tests"
        #        }
    }
    
    
    
    #    InModuleScope DevTools {
    #        
    #        
    #        
    #        #$OutputVariable = (dt DevTools Install) | Out-String
    #        
    #        
    #        It 'Outputs the correct message' {
    #            #{ Write-Host 1 } | Should be 1
    #        }
    #        
    #    }
    #    Context 'Strict mode' {
    #        
    #        Set-StrictMode -Version latest
    #
    #        #$result = dt -GenerateProject Test
    #        #$result = powershell -NoProfile dt DevTools Install
    #        #$result = powershell -NoProfile dt DevTools Install
    #        #Write-Host ($result)
    #        
    #        It 'Should succeed on event' {
    #            #$null | Should BeNullOrEmpty
    #            { throw "hello" } | Should be '111'
    #            #Write-Host($result)
    #            #$result | Should be 'Generating Test module.'
    #        }
    #        
    #        It 'Should error on event without parameter' {
    #            { throw "hello" } | Should Throw
    #        }
    #        
    #        It 'Should not error on event with parameter' {
    #            { } | Should Not Throw
    #        }
    #        
    #        It 'Should return true when event exists and parameter is used' {
    #            $true | Should be $True
    #        }
    #        
    #        It "Should return false when event doesn't exist or we time out and parameter is used" {
    #            $false | Should be $False
    #        }
    #    }
}