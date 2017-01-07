using namespace System.Management.Automation
using namespace System.Collections.ObjectModel


class DynamicParameter {
    
    $runtimeParameterDictionary = (New-Object RuntimeDefinedParameterDictionary)
    
    [Object]set($parameterAttribute, $validateSet, $projectName)
    {
        $validateSetAttribute = New-Object ValidateSetAttribute($validateSet)
        
        $attributeCollection = New-Object Collection[Attribute]
        $attributeCollection.Add($parameterAttribute)
        $attributeCollection.Add($validateSetAttribute)
        
        $definedParameter = New-Object RuntimeDefinedParameter(
            $projectName, [String],
            $attributeCollection
        )
        
        $this.runtimeParameterDictionary.Add($projectName, $definedParameter)
        
        return $this.runtimeParameterDictionary
    }
}