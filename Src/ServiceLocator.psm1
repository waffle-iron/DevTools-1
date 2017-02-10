using module Logger
using module .\LoggerDecorator.psm1

using module .\DesignPatterns\IServiceLocator

using module .\Config\IConfig.psm1
using module .\Config\DefaultConfig.psm1

using module .\Helper\DynamicParametersHelper.psm1
using module .\Helper\FileSystemHelper.psm1
using module .\Helper\TestSuiteHelper.psm1

using module .\Action\ActionMapper.psm1
using module .\Action\ActionFacade.psm1

using module .\Service\VersionService.psm1
using module .\Service\LocalDeploymentService.psm1
using module .\Service\AppVeyorService.psm1


using module .\Console\Localized\LocaleRepository.psm1

Set-StrictMode -Version latest

class ServiceLocator: IServiceLocator
{
    ServiceLocator (): base ()
    {
        #Logger
        $logger = New-Object LoggerDecorator
        $logger.logEntryType = [Logger.LoggerEntryTrimmed]
        $logger.appenders.add([Logger.ColoredConsoleAppender]@{ })
        $this.add([ILogger], $logger)
        
        #DefaultConfig
        $defaultConfig = [DefaultConfig]@{ logger = $logger }
        $this.add([IConfig], $defaultConfig)
        
        $defaultProperties = @{
            logger = $logger
            config = $defaultConfig
        }
        
        #DynamicParametersHelper
        $this.add([DynamicParametersHelper]$defaultProperties)
        
        #FileSystemHelper
        $this.add([FileSystemHelper]$defaultProperties)
        
        #LocaleRepository
        $this.add([LocaleRepository]$defaultProperties)
        
        # Expose locale to global scope through locale function
        $this.get([LocaleRepository]).expose()
        
        # Inject LocaleRepository into module config
        $this.get([IConfig]).locale = $this.get([LocaleRepository])
        
        #VersionService
        $this.add([VersionService]$defaultProperties)
        
        # Inject VersionService into module config
        $this.get([IConfig]).version = $this.get([VersionService])
        
        #LocalDeploymentService
        $this.add([LocalDeploymentService](
                $defaultProperties + @{ fileSystemHelper = $this.get([FileSystemHelper]) })
        )
        
        #AppVeyorService
        if ($ENV:APPVEYOR) { $this.add(([AppVeyorService]$defaultProperties).getInstance()) }
        
        #TestSuiteHelper
        $this.add([TestSuiteHelper](
                $defaultProperties + @{ appVeyorService = $this.get([AppVeyorService]) })
        )
        
        $services = @{
            localDeploymentService = $this.get([LocalDeploymentService])
            fileSystemHelper = $this.get([FileSystemHelper])
            appVeyorService = $this.get([AppVeyorService])
        }
        
        #ActionFacade
        $this.add([ActionFacade]($defaultProperties + $services))
        
        #ActionMapper
        $this.add([ActionMapper]$defaultProperties)
        
        #Subscribe LocaleRepository to ActionMapper
        $this.get([ActionMapper]).subscribe($this.get([LocaleRepository]))
        
        #Subscribe ActionFacade to ActionMapper
        $this.get([ActionMapper]).subscribe($this.get([ActionFacade]))
    }
}