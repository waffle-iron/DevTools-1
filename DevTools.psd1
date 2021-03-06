@{
    RootModule = 'DevTools.psm1'
    ModuleVersion = '1.1.8'
    GUID = '6db91827-46cb-40b5-8843-ed393f350132'
    Author = 'G8t Guy'
    CompanyName = 'Unknown'
    Copyright = '(c) 2016 G8t Guy, licensed under MIT License.'
    Description = 'A set of tools aiming to help develop, deploy and test the PowerShell modules.'
    PowerShellVersion = '5.0'
    HelpInfoURI = 'https://github.com/g8tguy/DevTools/blob/master/README.md'
    
    #    RequiredModules = @(
    #        @{ ModuleName = 'LibPosh'; RequiredVersion = '1.0.10' },
    #        @{ ModuleName = 'Pester'; RequiredVersion = '3.4.3' }
    #        @{ ModuleName = 'Logger'; RequiredVersion = '1.0.3' }
    #    )
    
    RequiredAssemblies = @('System.IO.Compression.FileSystem')
    
    NestedModules = @(
        'Src\ServiceLocator.psm1'
        #        'Src\Manager\AppVeyorManager.psm1',
        #        'Src\Manager\BadgeManager.psm1',
        #        'Src\Manager\ModuleManager.psm1',
        #        'Src\Manager\ProvisionManager.psm1',
        #        'Src\Manager\VersionManager.psm1',
        #        'Src\DynamicConfig.psm1',
        #        'Src\Enums.psm1'
    )
    
    FileList = @('Src', 'DevTools.psd1', 'DevTools.psm1')
    
    FunctionsToExport = @('Use-DevTools')
    AliasesToExport = 'dt'
    
    PrivateData = @{
        PSData = @{
            Tags = @('deploy', 'build', 'provision', 'dev', 'tools', 'devops', 'appveyor')
            LicenseUri = 'https://github.com/g8tguy/DevTools/blob/master/LICENSE'
            ProjectUri = 'https://github.com/g8tguy/DevTools'
            IconUri = 'https://raw.githubusercontent.com/g8tguy/DevTools/master/Docs/Logo/logo.png'
            ReleaseNotes = '
Check out the project site for more information:
https://github.com/g8tguy/DevTools'
        }
        DevTools = @{
            PSGalleryDeployLocally = $true
            Dependencies = @(
                @{ deploy = $false; name = 'LibPosh'; github = 'https://github.com/g8tguy/LibPosh' }
                @{ deploy = $false; name = 'Logger'; github = 'https://github.com/g8tguy/Logger' }
            )
        }
    }
}
