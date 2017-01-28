﻿using module DevTools
using namespace DevTools

$global:verbose = $true

$global:result = [String]::Empty

[HashTable]$state = @{
    CI = $env:CI
    PLATFORM = $env:PLATFORM
    APPVEYOR_BUILD_FOLDER = $env:APPVEYOR_BUILD_FOLDER
    APPVEYOR_REPO_TAG = $env:APPVEYOR_REPO_TAG
    APPVEYOR_REPO_BRANCH = $env:APPVEYOR_REPO_BRANCH
    PWD = $pwd
}

$writeHostMock = {
    Mock -ModuleName DynamicConfig `
         –ParameterFilter { $ForegroundColor –ne 'Blue' } `
         -CommandName Write-Host -MockWith {
        

        
        if ($verbose) { Microsoft.PowerShell.Utility\Write-Host $text -ForegroundColor Blue }
        
        $global:result += $text
    }
}

$restoreState = {
    $env:CI = $state.CI
    $env:APPVEYOR_BUILD_FOLDER = $state.APPVEYOR_BUILD_FOLDER
    $env:APPVEYOR_REPO_TAG = $state.APPVEYOR_REPO_TAG
    $env:APPVEYOR_REPO_BRANCH = $state.APPVEYOR_REPO_BRANCH
    $env:PLATFORM = $state.PLATFORM
}