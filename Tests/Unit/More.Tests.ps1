

Describe "Project Structure" {
    Context "When there are changes" {
        $result = 1.2
        It "Returns the next version number" {
            $result | Should Be 1.2
        }
    }

}