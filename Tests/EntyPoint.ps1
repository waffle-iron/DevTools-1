﻿using namespace System.Net
using module DevTools

$provision = $global:devTools.provision
$version = $global:devTools.version
$appVeyor = $global:devTools.appVeyor

#$outputFile = '{0}\{1}-{2}.NUnit.xml' -f (
#    $env:TEMP,
#    $provision.projectName,
#    $version.version
#)

$config = @{
    path = $provision.tests
    outputFormat = 'NUnitXml' 
    outputFile = '{0}\{1}-{2}.NUnit.xml' -f (
        $env:TEMP,
        $provision.projectName,
        $version.version
    )
    passThru = $true
}

$test = Invoke-Pester @config

if (!$appVeyor) { return }

$target = 'https://ci.appveyor.com/api/testresults/nunit/{0}' -f $env:APPVEYOR_JOB_ID

$message  = "{0}Uploading {1} to {2}" -f $provision.cr, $config.outputFile, $target
$provision.warning($message)
Add-AppveyorMessage -Message $message -Category Information

(New-Object WebClient).UploadFile($target, $config.outputFile)

if (!$test.FailedCount) { return }

$message = '{0}Failed tests count : {1}' -f ($provision.cr, $test.FailedCount)

Add-AppveyorMessage $message Error

throw $message