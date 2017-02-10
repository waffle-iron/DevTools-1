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
        
        $defaultDataSet = @{
            logger = $logger
            config = $defaultConfig
        }
        
        #LocaleRepository
        $this.add([LocaleRepository]$defaultDataSet)
        
        # Inject LocaleRepository into module config
        $this.get([IConfig]).locale = $this.get([LocaleRepository])
        
        #DynamicParametersHelper
        $this.add([DynamicParametersHelper]$defaultDataSet)
        
        #LocalDeploymentService
        $this.add([LocalDeploymentService]$defaultDataSet)
        
        #AppVeyorService
        if ($ENV:APPVEYOR) { $this.add(([AppVeyorService]$defaultDataSet).getInstance()) }
        
        #FileSystemHelper
        $this.add([FileSystemHelper]$defaultDataSet)
        
        #TestSuiteHelper
        $this.add([TestSuiteHelper]$defaultDataSet)
        
        $services = @{
            localDeploymentService = $this.get([LocalDeploymentService])
            fileSystemHelper = $this.get([FileSystemHelper])
        }
        
        #ActionFacade
        $this.add([ActionFacade]($defaultDataSet + $services))
        
        #ActionMapper
        $this.add([ActionMapper]$defaultDataSet)
        
        #Subscribe LocaleRepository to ActionMapper
        $this.get([ActionMapper]).attach($this.get([LocaleRepository]))
        
        #Subscribe ActionFacade to ActionMapper
        $this.get([ActionMapper]).attach($this.get([ActionFacade]))
    }
}