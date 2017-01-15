using namespace System.Management.Automation
using namespace System.Collections.ObjectModel

using namespace System.Management.Automation.Host
using namespace System.Management.Automation
using namespace System.Collections.Generic

class DynamicParamFactory {
    
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