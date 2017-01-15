Describe "Tests Suit 2" {
    Context "Context 2" {
        
        $result = 1
        
        It "Test 1" { $result | Should Be 1 }
        
        It "Test 2" { $result | Should Not Be 0 }
        
        It "Test 3" { $result | Should Be 1 }
    }
}