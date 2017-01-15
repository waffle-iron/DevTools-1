using namespace System.Management.Automation.Host
using namespace System.Management.Automation
using namespace System.Collections.ObjectModel
using namespace System.Collections.Generic

using module .\Src\ProvisionManager.psm1
using module .\Src\VersionManager.psm1
using module .\Src\AppVeyorManager.psm1

#$global:devTools = [Hashtable]::Synchronized(@{ })

$global:devTools = @{ }

$devTools.appVeyor = New-Object AppVeyorManager

$devTools.config = switch ([Boolean]$env:CI)
{
    true { $devTools.appVeyor.getConfig() }
    false { Import-PowerShellDataFile $env:USERPROFILE\dev_tools_config.psd1 }
}

$devTools.projects = {
    (Get-ChildItem $devTools.config.projectsPath).forEach{
        if ($_.length -eq $true) { $_.name }
    }
}

function Use-DevTools
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromRemainingArguments = $true)]
        $CustomVersion = $false,
        [Switch]$NoPublish
    )
    
    DynamicParam
    {
        $runtimeParameterDictionary = New-Object RuntimeDefinedParameterDictionary
        
        $projectName = 'Project'
        
        $attributeCollection = New-Object Collection[System.Attribute]
        
        $parameterAttribute = New-Object ParameterAttribute
        
        $devTools.location = (Get-Item -Path $pwd)
        $devTools.path = $devTools.location.FullName
        $devTools.project = $devTools.location.Name
        $devTools.isInProject = Test-Path ('{0}\{1}.psd1' -f $devTools.path, $devTools.project)
        
        
        if ($devTools.isInProject)
        {
            $parameterAttribute.Position = 2
            $PSBoundParameters[$projectName] = $devTools.project
        } else
        {
            $parameterAttribute.Position = 1
            $parameterAttribute.Mandatory = $true
        }
        
        $attributeCollection.Add($parameterAttribute)
        
        $validateSetAttribute = New-Object ValidateSetAttribute($devTools.projects.Invoke())
        
        $attributeCollection.Add($validateSetAttribute)
        
        $rtDefinedParameter = New-Object RuntimeDefinedParameter($projectName, [String], $attributeCollection)
        
        $runtimeParameterDictionary.Add($projectName, $rtDefinedParameter)
        
        $actionName = 'Action'
        
        $attributeCollection = New-Object Collection[System.Attribute]
        
        $parameterAttribute = New-Object ParameterAttribute
        $parameterAttribute.Mandatory = $false
        
        $parameterAttribute.Position = switch ($devTools.isInProject)
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
        $root = '{0}\{1}\Tests' -f $devTools.config.projectsPath, $project
        
        $devTools.provision = $provision = [ProvisionManager]@{ root = $root }
        $devTools.version = $version = [VersionManager]@{ psd = $provision.psd }
        
        $provision.info('Version : {0}' -f [String]$version.version)
        $provision.info('Project : {0}' -f [String]$project)
        $provision.info('System  : {0} {1}' -f ($Env:PROCESSOR_ARCHITECTURE, $devTools.config.environment))
        $provision.info('Action  : {0}' -f $action)
        
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
            ([Action]::Build) { $devTools.appVeyor.pushArtifact($provision, $version.version) }
            ([Action]::Release)
            {
                $provision.bumpVersion($version, $nextVersion)
                $provision.gitCommitVersionChange($nextVersion)
                $provision.gitTag($nextVersion)
                
                if ($noPublish.isPresent) { break }
                
                $provision.publish()
            }
            ([Action]::Cleanup) { $provision.cleanup() }
            ([Action]::Install) { $provision.install() }
            ([Action]::CopyToCurrentUserModules) { $provision.copy() }
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
        
        $provision.warning('{0}Test Environment : Redy' -f $provision.cr)
        
        # powershell -NoProfile $provision.entryPoint
        # . $provision.entryPoint
        Invoke-Expression $provision.entryPoint
        
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
    
    if (($devTools.isInProject -and $count -eq 2) -or (!$devTools.isInProject -and $count -eq 1))
    {
        $methods = $devTools.projects.invoke()
    }
    
    if ($count -eq 3)
    {
        $methods = [Enum]::GetValues([VersionComponent])
    }
    
    $matches = $methods | Where-Object { $_ -like "*$wordToComplete*" }
    
    $matches = switch ([Boolean]$matches.Count) { True { $matches } False { $methods } }
    
    $matches | Sort-Object | ForEach-Object { [CompletionResult]::new($_) }
}