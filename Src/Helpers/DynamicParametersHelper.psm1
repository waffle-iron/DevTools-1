using module LibPosh

using module ..\GenericTypes.psm1
using module .\AbstactHelper.psm1

class DynamicParametersHelper: AbstactHelper
{
    
    [Object]build([ref]$boundParameters)
    {
       # Write-Host((Get-PSCallStack)[2].Position.Text | Format-List | out-string)


        $dpf = New-Object LibPosh.DynamicParameter
        
        # Project
        $projectField = 'Project'
        $parameterAttribute = $dpf.getParameterAttribute(@{ position = 1; mandatory = $true })
        
        if ($this.configContainer.isInProject)
        {
            $parameterAttribute.position = 2
            $parameterAttribute.mandatory = $false
            $boundParameters.value[$projectField] = $this.configContainer.currentDirectoryName
        }
        
        #$projects = $this.getProjects()
        $projects = ,('DevTools')
        
        #$rawParameters = -split $myinvocation.line
        $rawParameters = -split (Get-PSCallStack)[2].Position.Text
        
        [Boolean]$generateProject = $rawParameters -contains 'GenerateProject'
        
        if ($generateProject)
        {
            $newProject = switch ($rawParameters[$true] -eq 'GenerateProject')
            {
                true { $rawParameters[2] }
                false { $rawParameters[1] }
            }
            
            if ($projects -notcontains $newProject)
            {
                $parameterAttribute.mandatory = $false
                $projects += $newProject
            }
        }
        
        [Void]$dpf.set($parameterAttribute, $projects, $projectField)
        
        # Action
        $actionField = 'Action'
        
        $parameterAttribute = $dpf.getParameterAttribute()
        $parameterAttribute.mandatory = $false
        $parameterAttribute.position = switch ($this.configContainer.isInProject)
        {
            True { 1 }
            Default { 2 }
        }
        
        $boundParameters.value[$actionField] = [ActionType]::Test
        
        [Void]$dpf.set($parameterAttribute, [Enum]::getValues([ActionType]), $actionField)
        
        # VersionType
        $versionField = 'VersionType'
        $parameterAttribute = $dpf.getParameterAttribute(@{ position = 3 })
        $parameterAttribute.mandatory = $false
        $parameterAttribute.position = 3
        $boundParameters.value[$versionField] = [VersionComponent]::Build

        return $dpf.set($parameterAttribute, ('Major', 'Minor', 'Build'), $versionField)
    }
}