using namespace System.Management.Automation.Host
using namespace System.Management.Automation
using namespace System.Collections.ObjectModel
using namespace System.Collections.Generic

using module .\Src\ProvisionManager.psm1
using module .\Src\VersionManager.psm1
using module .\Src\AppVeyorManager.psm1

$script:sync = [Hashtable]::Synchronized(@{ })

$sync.config = Import-PowerShellDataFile $env:USERPROFILE\dev_tools_config.psd1

#$APPVEYOR_BUILD_FOLDER = $sync.config.projectsPath
#$CI = $true

$sync.config = switch ([Boolean]$env:CI)
{
    true {
        @{
            apiKey = ''
            projectsPath = $env:APPVEYOR_BUILD_FOLDER
        }
    }
    false { Import-PowerShellDataFile $env:USERPROFILE\dev_tools_config.psd1 }
}


$sync.projects = {
    (Get-ChildItem $sync.config.projectsPath).forEach{
        if ($_.length -eq $true) { $_.name }
    }
}

function Use-DevTools
{
    [CmdletBinding()]
    param
    (
    [Parameter(ValueFromRemainingArguments = $true)]
    $CustomVersion = $false
    )
    
    DynamicParam
    {
        $runtimeParameterDictionary = New-Object RuntimeDefinedParameterDictionary
        
        $projectName = 'Project'
        
        $attributeCollection = New-Object Collection[System.Attribute]
        
        $parameterAttribute = New-Object ParameterAttribute
        
        $sync.location = (Get-Item -Path $pwd)
        $sync.path = $sync.location.FullName
        $sync.project = $sync.location.Name
        $sync.isInProject = Test-Path ('{0}\{1}.psd1' -f $sync.path, $sync.project)
        
        
        if ($sync.isInProject)
        {
            $parameterAttribute.Position = 2
            $PSBoundParameters[$projectName] = $sync.project
        } else
        {
            $parameterAttribute.Position = 1
            $parameterAttribute.Mandatory = $true
        }
        
        $attributeCollection.Add($parameterAttribute)
        
        $validateSetAttribute = New-Object ValidateSetAttribute($sync.projects.Invoke())
        
        $attributeCollection.Add($validateSetAttribute)
        
        $rtDefinedParameter = New-Object RuntimeDefinedParameter($projectName, [String], $attributeCollection)
        
        $runtimeParameterDictionary.Add($projectName, $rtDefinedParameter)
        
        $actionName = 'Action'
        
        $attributeCollection = New-Object Collection[System.Attribute]
        
        $parameterAttribute = New-Object ParameterAttribute
        $parameterAttribute.Mandatory = $false
        
        $parameterAttribute.Position = switch ($sync.isInProject)
        {
            True { 1 }
            Default { 2 }
        }
        
        $attributeCollection.Add($parameterAttribute)
        
        $validateSetAttribute = New-Object ValidateSetAttribute([Enum]::GetValues([Action]))
        
        $attributeCollection.Add($validateSetAttribute)
        
        $rtDefinedParameter = New-Object RuntimeDefinedParameter($actionName, [String], $attributeCollection)
        $PSBoundParameters[$actionName] = [Action]::Test
        
        $runtimeParameterDictionary.Add($actionName, $rtDefinedParameter)
        
        $versionName = 'VersionType'
        
        $attributeCollection = New-Object Collection[System.Attribute]
        
        $parameterAttribute = New-Object ParameterAttribute
        $parameterAttribute.Mandatory = $false
        
        $parameterAttribute.Position = 3
        
        
        $attributeCollection.Add($parameterAttribute)
        
        $validateSetAttribute = New-Object ValidateSetAttribute('Major', 'Minor', 'Build')
        
        $attributeCollection.Add($validateSetAttribute)
        
        $rtDefinedParameter = New-Object RuntimeDefinedParameter($versionName, [String], $attributeCollection)
        $PSBoundParameters[$versionName] = [VersionComponent]::Build
        
        $runtimeParameterDictionary.Add($versionName, $rtDefinedParameter)
        
        return $runtimeParameterDictionary
    }
    begin
    {
        $project = $PsBoundParameters[$projectName]
        $action = $PsBoundParameters[$actionName]
        [VersionComponent]$versionType = $PsBoundParameters[$versionName]
    }
    process
    {
        $sync.config
        $root = '{0}\{1}\Tests' -f $sync.config.projectsPath, $project
        
        $provision = [ProvisionManager]@{ root = $root }
        $version = [VersionManager]@{ psd = $provision.psd }
        $appVeyor = [AppVeyorManagerManager]@{ }
        
        
        $provision.report('Project:{0}' -f [String]$project)
        $provision.report('Version:{0}' -f [String]$version.version)
        $provision.report('Action:{0}' -f $action)
        
        $nextVersion = switch ([Boolean]$customVersion)
        {
            True { $customVersion }
            Default { $version.next($VersionType) }
        }
        
        $projectConfig = Import-PowerShellDataFile $provision.psd
        
        $provision.dependencies = (
        @{
            deploy = $true
            name = $provision.projectName
        }
        )
        
        $provision.dependencies += $projectConfig.PrivateData.DevTools.Dependencies
        
        switch ($action)
        {
            ([Action]::Build) { $appVeyor.pushArtifact() }
            ([Action]::Cleanup) { $provision.cleanup() }
            ([Action]::Shortcuts) { $provision.shortcuts() }
            ([Action]::Copy) { $provision.copy() }
            ([Action]::BumpVersion) { $provision.bumpVersion($version, $nextVersion) }
            ([Action]::Publish) { $provision.publish() }
            ([Action]::Deploy)
            {
                $provision.bumpVersion($version, $nextVersion)
                $provision.publish()
            }
            default { }
        }
        
        if ($action -ne [Action]::Test) { return }
        
        $provision.report('The Test Environment is redy.')
        
        powershell -NoProfile $provision.entryPoint
    }
}

New-Alias -Name dt -Value Use-DevTools

Register-ArgumentCompleter -CommandName dt -ScriptBlock {
    param (
    $wordToComplete,
    $commandAst,
    $cursorPosition
    )
    
    $ast = (-split $commandAst)
    $count = $ast.Length
    $last = $ast[- $true]
    
    $methods = [Enum]::GetValues([Action])
    
    if (($sync.isInProject -and $count -eq 2) -or (!$sync.isInProject -and $count -eq 1))
    {
        $methods = $sync.projects.invoke()
    }
    
    if ($count -eq 3)
    {
        $methods = [Enum]::GetValues([VersionComponent])
    }
    
    $matches = $methods | Where-Object { $_ -like "*$wordToComplete*" }
    
    $matches = switch ([Boolean]$matches.Count) { True { $matches } False { $methods } }
    
    $matches | Sort-Object | ForEach-Object { [CompletionResult]::new($_) }
}