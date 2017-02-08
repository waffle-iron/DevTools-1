using module Logger

using module ..\CommonInterfaces.psm1

Set-StrictMode -Version latest





class AppVeyorService: IService
{
    [IService]getInstance()
    {
        $this.logger.appenders.add([Logger.AppVeyorAppender]@{ })
        return $this
    }
}