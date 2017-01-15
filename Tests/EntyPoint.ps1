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
#
#$test = Invoke-Pester -Path "$($provision.tests)" `
#                      -OutputFormat NUnitXml `
#                      -OutputFile "$outputFile" `
#                      -PassThru
#
#if (!$appVeyor) { return }
#
#$target = 'https://ci.appveyor.com/api/testresults/nunit/{0}' -f $env:APPVEYOR_JOB_ID
#
#$provision.warning("{0}Uploading $outputFile to $target" -f $provision.cr)
#
#
#(New-Object WebClient).UploadFile($target, $outputFile)
#
#if (!$test.FailedCount) { return }
#
#$provision.error('{0}Failed tests count : {1}' -f ($provision.cr, $test.FailedCount))
#
#exit ($test.FailedCount)
#
#Add-AppveyorMessage "This is a test message"
#Add-AppveyorCompilationMessage "Unreachable code detected" -Category Warning -FileName "Program.cs" -Line 1 -Column 3


$res = Invoke-Pester -Path ".\Tests" -OutputFormat NUnitXml -OutputFile ".\TestsResults.xml" -PassThru
(New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path .\TestsResults.xml))
if ($res.FailedCount -gt 0) { throw "$($res.FailedCount) tests failed."}