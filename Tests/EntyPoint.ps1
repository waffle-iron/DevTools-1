using namespace System.Net

using module DevTools

#get-variable -scope global

$provision = $global:devTools.provision
$version = $global:devTools.version
$appVeyor = $global:devTools.appVeyor

$outputFile = '{0}\{1}-{2}.NUnit.xml' -f (
    $provision.temp,
    $provision.projectName,
    $version.version
)

$test = Invoke-Pester -Path "$($provision.tests)" `
                      -OutputFormat NUnitXml `
                      -OutputFile "$outputFile" `
                      -PassThru

if (!$appVeyor) { return }


$target = 'https://ci.appveyor.com/api/testresults/nunit/{0}' -f $env:APPVEYOR_JOB_ID

$provision.warning("{0}Uploading $outputFile to $target" -f $provision.cr)

#(New-Object WebClient).UploadFile($target, $outputFile)

$WebClient = New-Object -TypeName 'System.Net.WebClient'
$WebClient.UploadFile($target, "$outputFile")

if (!$test.FailedCount) { return }

$provision.error('{0}Failed tests count : {1}' -f ($provision.cr, $test.FailedCount))

exit ($test.FailedCount)

