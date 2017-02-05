Set-StrictMode -Version latest

Use-DevTools Install NewModule
Use-DevTools CopyToCurrentUserModules NewModule
Use-DevTools Uninstall NewModule

$location = $PWD

Use-DevTools GenerateProject NewMod

Set-Location ..

Use-DevTools NewMod GenerateProject

Set-Location $location