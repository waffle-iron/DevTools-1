using module Logger

using module ..\CommonInterfaces.psm1

Set-StrictMode -Version latest

class ModuleGeneratorService: IService
{
    [Object]$fileSystemHelper

    generate()
    {
        $src = 'D:\User\Development\OpenSource\Current\Powershell\DevTools\Assets\BoilerplateModule'
        $dest = 'C:\TEMP\BoilerplateModule'
        $this.logger.list($this.fileSystemHelper.synchronizeDirectory($src, $dest))
    }
}
