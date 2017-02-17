#requires -Version 5.0

using module ..\MODULE_NAME.psm1

$global:codeSmell = $true

# You can set breakpoints in an IDE (ISE, Powershell Studio, VSCode)
# Or just use powershell native debugging (set-psbreakpoint)
#
# powershell -noprofile .\MODULE_NAME\Tests\DebugEntryPoint.ps1

if ($host.name -notmatch 'PrimalScriptHostImplementation')
{
    set-psbreakpoint -variable me >$null
}

Test-MODULE_NAME Bobby
