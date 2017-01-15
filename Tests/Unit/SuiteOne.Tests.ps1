Describe 'Tests Suit 1' {
    Context 'Strict mode' {
        
        Set-StrictMode -Version latest
        
        It 'Should succeed on event' {
            $Output = $null
            $Output | Should BeNullOrEmpty
            $true | Should be $True
        }
        
        It 'Should error on event without parameter' {
            { throw "hello" } | Should Throw
        }
        
        It 'Should not error on event with parameter' {
            { } | Should Not Throw
        }
        
        It 'Should return true when event exists and parameter is used' {
            $true | Should be $True
        }
        
        It "Should return false when event doesn't exist or we time out and parameter is used" {
            $false | Should be $False
        }
    }
}
