Describe 'ModuleName Tests' {
    Context 'Pester primitives' {
        
        Set-StrictMode -Version latest
        
        It 'Should succeed' {
            $null | Should BeNullOrEmpty
            $true | Should Be $true
        }
        
        It 'Should error' {
            { throw 'error' } | Should Throw
        }
        
        It 'Should not error' {
            { } | Should Not Throw
        }
        
        It 'Should return true' {
            $true | Should Be $True
        }
        
        It "Should return false" {
            $false | Should Be $False
        }
    }
}