Set-StrictMode -Version latest

Use-DevTools Install

$location = $PWD

Use-DevTools GenerateProject NewMod

Set-Location ..

Use-DevTools NewMod GenerateProject

Set-Location $location