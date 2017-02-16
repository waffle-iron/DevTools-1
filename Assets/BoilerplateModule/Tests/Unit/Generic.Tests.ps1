# This script is invoked by DevTools,
# so it exists in the same scope
# and shares it's public variables:
# [TestSuiteHelper]$this
# $this.config, $this.logger, $this.config.serviceLocator, etc

Set-StrictMode -Version latest

# Expose some useful variables
$config, $logger, $testSuite = $this.config, $this.logger, $this

. ('{0}\Unit\SharedFixtures' -f $config.testsPath)

Describe 'MODULE_NAME Unit Tests' {
    Context 'MODULE_NAME Greetings' {
        
        Set-StrictMode -Version latest
        
        $result = MODULE_NAME 'MODULE_AUTHOR'
        
        It 'Should Not Be Null Or Empty' {
            $result | Should Not BeNullOrEmpty
        }
        
        It 'Should Be String' {
            $result | Should BeOfType String
        }
        
        It 'Should Contain MODULE_AUTHOR' {
            $result[3] | Should Match 'MODULE_AUTHOR'
        }
        
        It 'Casting To Boolean Should be True' {
            [Boolean]$result | Should Be $True
        }
        
        It 'Should Not Throw' {
            { } | Should Not Throw
        }
        
        Mock -CommandName MODULE_NAME { Throw }
        
        It 'Mock Object Should Throw' {
            { MODULE_NAME Greetings } | Should Throw
        }
    }
}