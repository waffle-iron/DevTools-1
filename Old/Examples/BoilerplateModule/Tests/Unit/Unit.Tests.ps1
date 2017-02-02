Set-StrictMode -Version latest

. ('{0}\Unit\SharedFixtures' -f $devTools.testsPath)

Describe 'ModuleName Unit Tests' {
    Context 'Get-ModuleName Greetings' {
        
        Set-StrictMode -Version latest
        
        $result = Get-ModuleName Greetings
        
        It 'Should Not Be Null Or Empty' {
            $result | Should Not BeNullOrEmpty
        }
        
        It 'Should Be String' {
            $result | Should BeOfType String
        }
        
        It 'Should Contain Greetings' {
            $result | Should Match Greetings
        }
        
        It 'Casting To Boolean Should be True' {
            [Boolean]$result | Should Be $True
        }
        
        It 'Should Not Throw' {
            { } | Should Not Throw
        }
        
        Mock -CommandName Get-ModuleName { Throw }
        
        It 'Mock Object Should Throw' {
            { Get-ModuleName Greetings } | Should Throw
        }
    }
}