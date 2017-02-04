$projectsPath = 'C:\projects'

$content = '@{
    projectsPath = "{projectsPath}"
    psGalleryApiKey = $null

    userInfo = (
        @{
            gitHubSlug = $null
            userName = $null
            gitHubAuthToken = $null
        }
    )
}' -replace '{projectsPath}', $projectsPath

[IO.FileInfo]$file = '{0}\.devtools' -f $ENV:USERPROFILE
$content | Set-Content $file

Write-Host $file
Write-Host $projectsPath