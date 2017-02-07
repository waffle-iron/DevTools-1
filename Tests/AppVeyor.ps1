#$content = '@{
#    projectsPath = "c:\projects"
#    psGalleryApiKey = $null
#
#    userInfo = (
#        @{
#            gitHubSlug = $null
#            userName = $null
#            gitHubAuthToken = $null
#        }
#    )
#}'
#
#[IO.FileInfo]$file = '{0}\.devtools' -f $ENV:USERPROFILE
#$content | Set-Content $file


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