$location = $PWD

dt GenerateProject NewMod

Set-Location ..

dt NewMod GenerateProject

Set-Location $location