#requires -Version 5.0

using module ..\ModuleName.psm1

# You can set breakpoints in an IDE (ISE, Powershell Studio, VSCode)
# Or just use powershell native debugging (set-psbreakpoint)
#
# powershell -noprofile .\ModuleName\Tests\DebugEntryPoint.ps1

if ($host.name -notmatch 'PrimalScriptHostImplementation')
{
    set-psbreakpoint -variable variable >$null
}

Get-ModuleName Test
