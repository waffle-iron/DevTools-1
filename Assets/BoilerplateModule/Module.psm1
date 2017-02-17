using module .\Src\Poppy.psm1

Set-StrictMode -Version latest

function Test-MODULE_NAME
{
    param
    (
        [String]$variable
    )
    
    $poppy = New-Object Poppy
    
    $me = switch ([Boolean]$variable) { true { $variable }; false { [MeType]::Null } }
    
    $poppy.greetings('MODULE_NAME')
    $poppy.whoCreatedYou('MODULE_AUTHOR')
    $poppy.whereCanIFindHim('GITHUB_USER_NAME')
    $poppy.whatDoYouThinkAbout($me)
}

New-Alias -Name MODULE_NAME -Value Test-MODULE_NAME
