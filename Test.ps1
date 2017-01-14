

$ProjectRoot = $ENV:APPVEYOR_BUILD_FOLDER

#$outputFile = '{0}\{1}-{2}.NUnit.xml' -f (
#    $ProjectRoot,
#    "DevTools",
#    "1.1.5"
#)

$outputFile = "$ProjectRoot\log.xml"

$test = Invoke-Pester -Path "$ProjectRoot\Tests" `
                      -OutputFormat NUnitXml `
                      -OutputFile "$outputFile" `
                      -PassThru

$AppVeyorBuildJobId = $env:APPVEYOR_JOB_ID

#$target = "https://ci.appveyor.com/api/testresults/nunit/$AppVeyorBuildJobId"

$target = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"

Write-Host(Get-Content $outputFile | Out-String)

$WebClient = New-Object -TypeName 'System.Net.WebClient'

$responseArray = $WebClient.UploadFile($target, $outputFile)

Write-Host 'zzzzzzzzzz'
