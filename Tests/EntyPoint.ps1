using namespace System.Net
using module DevTools

$provision = $global:devTools.provision
$version = $global:devTools.version
$appVeyor = $global:devTools.appVeyor

$outputFile = '{0}\{1}-{2}.NUnit.xml' -f (
    $env:TEMP,
    $provision.projectName,
    $version.version
)

$pesterConfig = @{
    path = $provision.tests
    outputFormat = 'NUnitXml' 
    outputFile = $outputFile
    passThru = $true
}

#$test = Invoke-Pester -Path "$($provision.tests)" `
#                      -OutputFormat NUnitXml `
#                      -OutputFile "$outputFile" `
#                      -PassThru

$test = Invoke-Pester @pesterConfig

if (!$appVeyor) { return }

$target = 'https://ci.appveyor.com/api/testresults/nunit/{0}' -f $env:APPVEYOR_JOB_ID

$message  = "{0}Uploading $outputFile to $target" -f $provision.cr
$provision.warning($message)
Add-AppveyorMessage -Message $message -Category Information

(New-Object WebClient).UploadFile($target, $outputFile)

if (!$test.FailedCount) { return }

$message = '{0}Failed tests count : {1}' -f ($provision.cr, $test.FailedCount)

Add-AppveyorMessage -Message $message -Category Error

throw $message