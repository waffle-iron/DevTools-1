'@{
    projectsPath = "c:\projects"
    psGalleryApiKey = $null

    userInfo = (
        @{
            gitHubSlug = $null
            userName = $null
            gitHubAuthToken = $null
        }
    )
}' | Set-Content $ENV:USERPROFILE\.devtools