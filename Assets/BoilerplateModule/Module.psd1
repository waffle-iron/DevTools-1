@{
    rootModule = 'MODULE_NAME.psm1'
    moduleVersion = '1.0.0'
    GUID = 'NEW_GUID'
    author = 'MODULE_AUTHOR'
    companyName = 'Unknown'
    copyright = '(c) 2016 MODULE_AUTHOR, licensed under MIT License.'
    description = 'A PowerShell module.'
    powerShellVersion = '5.0'
    helpInfoURI = 'https://github.com/GITHUB_USER_NAME/MODULE_NAME/blob/master/README.md'
    
    requiredModules = @()
    requiredAssemblies = @()
    nestedModules = @()
    
    fileList = @('Src', 'MODULE_NAME.psd1', 'MODULE_NAME.psm1')
    
    functionsToExport = 'Test-MODULE_NAME'
    aliasesToExport = 'MODULE_NAME'
    
    privateData = @{
        PSData = @{
            tags = @('MODULE_NAME', 'Powershell', 'Module')
            licenseUri = 'https://github.com/GITHUB_USER_NAME/MODULE_NAME/blob/master/LICENSE'
            projectUri = 'https://github.com/GITHUB_USER_NAME/MODULE_NAME'
            iconUri = 'https://raw.githubusercontent.com/GITHUB_USER_NAME/MODULE_NAME/master/Docs/Logo/logo.png'
            releaseNotes = '
Check out the project site for more information:
https://github.com/GITHUB_USER_NAME/MODULE_NAME'
        }
    }
}
