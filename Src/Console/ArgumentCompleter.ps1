Register-ArgumentCompleter -CommandName ('dt', 'Use-DevTools') -ScriptBlock {
    param (
        $wordToComplete,
        $commandAst,
        $cursorPosition
    )
    
    $ast = (-split $commandAst)
    $count = $ast.length
    $last = $ast[-1]
    
    if ($last) { }
    
    $methods = [Enum]::getValues([ActionType])
    
    if (($config.isInProject -and $count -eq 2) -or (!$config.isInProject -and $count -eq 1))
    {
        $methods = $config.getProjects()
    }
    
    if ($count -eq 3) { $methods = [Enum]::getValues([VersionComponent]) }
    
    $matches = $methods | Where-Object { $_ -like "*$wordToComplete*" }
    
    $matches = switch ([Boolean]$matches.count) { True { $matches } False { $methods } }
    
    $matches | Sort-Object | ForEach-Object { [Management.Automation.CompletionResult]::new($_) }
}
