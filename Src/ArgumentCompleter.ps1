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
    
    $methods = [Enum]::GetValues([Action])
    
    if (($devTools.isInProject -and $count -eq 2) -or (!$devTools.isInProject -and $count -eq 1))
    {
        $methods = $devTools.getProjects()
    }
    
    if ($count -eq 3) { $methods = [Enum]::GetValues([VersionComponent]) }
    
    $matches = $methods | Where-Object { $_ -like "*$wordToComplete*" }
    
    $matches = switch ([Boolean]$matches.Count) { True { $matches } False { $methods } }
    
    $matches | Sort-Object | ForEach-Object { [CompletionResult]::new($_) }
}
