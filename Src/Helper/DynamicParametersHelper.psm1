Using module LibPosh

using module ..\GenericTypes.psm1
using module ..\CommonInterfaces.psm1

Set-StrictMode -Version latest

class DynamicParametersHelper: IHelper
{
    [Object]build([ref]$boundParameters)
    {
        $this.config.validateCurrentLocation()
        
        $dp = New-Object LibPosh.DynamicParameter
        
        # Project
        $moduleField = 'Module'
        $attribute = $dp.getParameterAttribute(@{ position = 1; mandatory = $true })
        
        if ($this.config.isInProject)
        {
            $attribute.position = 2
            $attribute.mandatory = $false
            $boundParameters.value[$moduleField] = $this.config.currentDirectoryName
        }
        
        $projects = $this.config.getProjects()
        
        $rawParameters = -split (Get-PSCallStack)[2].Position.Text
        
        [Boolean]$generateModule = $rawParameters -contains 'GenerateModule'
        
        if ($generateModule)
        {
            $newProject = switch ($rawParameters[$true] -eq 'GenerateModule')
            {
                true { $rawParameters[2] }
                false { $rawParameters[1] }
            }
            
            if ($projects -notcontains $newProject)
            {
                $attribute.mandatory = $false
                $projects += $newProject
            }
        }
        
        [Void]$dp.set($attribute, $projects, $moduleField)
        
        # Action
        $actionField = 'Action'
        
        $attribute = $dp.getParameterAttribute()
        $attribute.mandatory = $false
        $attribute.position = switch ($this.config.isInProject)
        {
            True { 1 }
            Default { 2 }
        }
        
        $boundParameters.value[$actionField] = [ActionType]::Test
        
        [Void]$dp.set($attribute, [Enum]::getValues([ActionType]), $actionField)
        
        # VersionType
        $versionField = 'VersionType'
        $attribute = $dp.getParameterAttribute(@{ position = 3 })
        $attribute.mandatory = $false
        $attribute.position = 3
        $boundParameters.value[$versionField] = [VersionComponent]::Build
        
        return $dp.set($attribute, [Enum]::getValues([VersionComponent]), $versionField)
    }
}