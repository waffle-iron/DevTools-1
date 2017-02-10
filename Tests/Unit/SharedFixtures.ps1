using namespace System.Collections

Set-StrictMode -Version latest

class Text: ArrayList
{
    [Int]$current = -1
    [Void]clear() { $this.current = -1; ([ArrayList]$this).clear() }
    [String]getLine([Int]$lineNumber) { return $this[($this.current = --$lineNumber)] }
    [String]nextLine() { return $this[++$this.current] }
    [String]previousLine() { return $this[--$this.current] }
}

Set-Variable pesterShared @{ } -Scope Global

$pesterShared.verbose = $true

$pesterShared.result = New-Object Text
$pesterShared.resulta = @()

$pesterShared.state = @{
    CI = $env:CI
    PLATFORM = $env:PLATFORM
    APPVEYOR_BUILD_FOLDER = $env:APPVEYOR_BUILD_FOLDER
    APPVEYOR_REPO_TAG = $env:APPVEYOR_REPO_TAG
    APPVEYOR_REPO_BRANCH = $env:APPVEYOR_REPO_BRANCH
    PWD = $pwd
}

$pesterShared.stateRestore = {
    $env:CI = $pesterShared.state.CI
    $env:PLATFORM = $pesterShared.state.PLATFORM
    $env:APPVEYOR_BUILD_FOLDER = $pesterShared.state.APPVEYOR_BUILD_FOLDER
    $env:APPVEYOR_REPO_TAG = $pesterShared.state.APPVEYOR_REPO_TAG
    $env:APPVEYOR_REPO_BRANCH = $pesterShared.state.APPVEYOR_REPO_BRANCH
}

$pesterShared.mocks = @{
    writeHost = {
        function global:Write-Host
        {
            param ($text)
            if ($pesterShared.verbose) { Microsoft.PowerShell.Utility\Write-Host $text @args }
            $pesterShared.result.add($text)
        }
    }
    writeHostAfterAll = { Remove-Item function:Write-Host }
    __writeHost = {
        Mock -ModuleName ColoredConsoleAppender `
             –ParameterFilter { $ForegroundColor –ne [ConsoleColor]::Blue } `
             -CommandName Write-Host -MockWith {
            
            param ([String]$object)
            
            # Smart GC
            if ($pesterShared.result.current -ge $false) { $pesterShared.result.clear() }
            
            if ($pesterShared.verbose)
            {
                $host.UI.WriteLine(
                    [ConsoleColor]::Black,
                    [ConsoleColor]::Blue,
                    'PESTER VERBOSE: {0}' -f $object
                )
            }
            $pesterShared.result.add($object)
        }
    }
}