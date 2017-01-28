function Get-ModuleName
{
    param
    (
        [String]$variable
    )
    
    $variable = 'Test {0}' -f $variable
    
    $variable
}

New-Alias -Name ModuleName -Value Get-ModuleName
