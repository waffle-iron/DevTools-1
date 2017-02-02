Set-StrictMode -Version latest


 
Describe 'Check' {
    #Mock Use-DevTools –ParameterFilter { $Action –eq 'test' } -MockWith { }
    dt DevTools Install
    dt DevTools Test
}