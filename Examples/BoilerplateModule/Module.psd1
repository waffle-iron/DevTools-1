@{
    RootModule = 'ModuleName.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'NewGuid'
    Author = 'UserName'
    CompanyName = 'Unknown'
    Copyright = '(c) 2016 UserName, licensed under MIT License.'
    Description = 'A PowerShell module.'
    PowerShellVersion = '5.0'
    HelpInfoURI = 'https://github.com/GitHubSlug/ModuleName/blob/master/README.md'
    NestedModules = @()
    
    FunctionsToExport = 'Get-ModuleName'
    AliasesToExport = 'ModuleName'
    
    PrivateData = @{
        PSData = @{
            Tags = @('ModuleName', 'PowerShell', 'Module')
            LicenseUri = 'https://github.com/GitHubSlug/ModuleName/blob/master/LICENSE'
            ProjectUri = 'https://github.com/GitHubSlug/ModuleName'
            IconUri = 'https://raw.githubusercontent.com/GitHubSlug/ModuleName/master/Docs/Logo/logo.png'
            ReleaseNotes = '
Check out the project site for more information:
https://github.com/GitHubSlug/ModuleName'
        }
    }
}