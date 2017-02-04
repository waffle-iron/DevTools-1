# TODO Move to LibPosh
# TODO Add Lazzy Loading

using namespace System.ComponentModel
using namespace System.ComponentModel.Design
using namespace System.Collections.Generic

Set-StrictMode -Version latest

class IServiceLocator: IServiceProvider
{
    hidden [HashTable]$callbacks = @{ }
    hidden [HashTable]$types = @{ }
    hidden [IServiceContainer]$services
    
    IServiceLocator() { $this.services = New-Object ServiceContainer }
    
    hidden [IList[Object]] GetAllServices() { throw }
    hidden [IList[Type]] GetAllServicedTypes() { throw }
    hidden [Object]GetService([Type]$serviceType) { throw }
    
    [Void]add([Type]$serviceType, [Object]$object)
    {
        $this.types.add([String]$serviceType, $serviceType)
        $this.services.addService($serviceType, $object)
    }
    
    [Void]add([Object]$object) { $this.add($object.getType(), $object) }
    
    [Object]get([Type]$serviceType) { return $this.services.getService($serviceType) }
    
    [Object]get([String]$serviceName)
    {
        return $this.services.getService($this.types[$serviceName])
    }
    
    hidden [Void]addLazzy($serviceType, $callBack) { throw }
    hidden [Object]getLazzy([Type]$serviceType) { throw }
}