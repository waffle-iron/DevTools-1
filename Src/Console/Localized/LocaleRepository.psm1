using module .\ILocaleRepository.psm1

class LocaleRepository: ILocaleRepository
{
    LocaleRepository ($dataBag): base ($dataBag) { }
    
    [Void]renderTitle($action)
    {
        $cpu_architecture = switch ([Boolean]$ENV:PLATFORM)
        {
            true { 'CI {0}' -f $ENV:PLATFORM }
            false { $ENV:PROCESSOR_ARCHITECTURE }
        }
        
        $title = '{0} {1} {2} [{3} {4}]' -f $this.config.moduleName, '1.2.2', `
        $action, $cpu_architecture, $ENV:COMPUTERNAME
        
        $this.logger.information($title)
    }
}
