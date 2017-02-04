using module Logger

using module .\IServiceLocator

using module .\Config\IConfig.psm1
using module .\Config\DefaultConfig.psm1

using module .\Helper\DynamicParametersHelper.psm1


class ServiceLocator: IServiceLocator
{
    ServiceLocator (): base ()
    {
        # Logger
        $logger = New-Object Logger
        $logger.logEntryType = [Logger.LoggerEntryTrimmed]
        $logger.appenders.add([Logger.ColoredConsoleAppender]@{ })
        $this.add([ILogger], $logger)
        
        # DefaultConfig
        $defaultConfig = [DefaultConfig]@{ logger = $logger }
        $this.add([IConfig], $defaultConfig)
        
        # DynamicParametersHelper
        $this.add([DynamicParametersHelper]@{
                logger = $logger
                config = $defaultConfig
            })
    }
}
