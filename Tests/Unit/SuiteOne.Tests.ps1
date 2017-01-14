

Describe "Tests Suit 1" {
    Context "Context 1" {
        
        $result = 1
        
        It "Test 1" {
            $result | Should Be 1
        }
        
        It "Test 2" {
            $result | Should Be 1
        }
        
        It "Test 3" {
            $result | Should Be 1
        }
        
        It "Test 4" {
            {} | Should Not Throw
        }
    }
    
}