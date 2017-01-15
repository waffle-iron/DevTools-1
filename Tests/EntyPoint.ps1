using namespace System.Net

using module DevTools

#get-variable -scope global

$provision = $global:devTools.provision
$version = $global:devTools.version
$appVeyor = $global:devTools.appVeyor

$outputFile = '{0}\{1}-{2}.NUnit.xml' -f (
    $env:TEMP,
    $provision.projectName,
    $version.version
)

$test = Invoke-Pester -Path "$($provision.tests)" `
                      -OutputFormat NUnitXml `
                      -OutputFile "$outputFile" `
                      -PassThru

if (!$appVeyor) { return }

$AppVeyorBuildJobId = $env:APPVEYOR_JOB_ID

$target = "https://ci.appveyor.com/api/testresults/nunit/$AppVeyorBuildJobId"
#$target = 'https://ci.appveyor.com/api/testresults/nunit/{0}' -f $env:APPVEYOR_JOB_ID

#$Target = 'https://ci.appveyor.com/api/testresults/nunit/dgfwlbeqo9436t3b'


#$provision.warning("{0}Uploading $outputFile to $target" -f $provision.cr)

Write-Host(Get-Content $outputFile | Out-String)

#(New-Object WebClient).UploadFile($target, $outputFile)

$WebClient = New-Object -TypeName 'System.Net.WebClient'

$responseArray = $WebClient.UploadFile($target, $outputFile)

Write-Host($responseArray | Format-List | Out-String)

#if (!$test.FailedCount) { return }

#$provision.error('{0}Failed tests count : {1}' -f ($provision.cr, $test.FailedCount))

#exit ($test.FailedCount)

Add-AppveyorMessage "This is a test message"
Add-AppveyorCompilationMessage "Unreachable code detected" -Category Warning -FileName "Program.cs" -Line 1 -Column 3


Write-Host 111

