

Describe 'Wait-Path' {
    
    Context 'Strict mode' {
        
        Set-StrictMode -Version latest
        
        It 'Should succeed on known paths' {
            

            $Output = $null
            $Output | Should BeNullOrEmpty
            $true | Should be $True
        }
        
        It 'Should error on timeout without passthru' {
            { throw "hello" } | Should Throw
        }
        
        It 'Should not error on timeout with passthru' {
            {  } | Should Not Throw
        }
        
        It 'Should return true when paths exist and passthru is used' {
            $true | Should be $True
        }
        
        It "Should return false when paths don't exist or we time out and passthru is used" {
            $false | Should be $False
        }
    }
}
