# <img src="/Docs/Logo/dt.png" alt="Logo" width="48" align="left"/>  DevTools

[![Powershellgallery Badge][psgallery-badge]][psgallery-status]

A set of tools for the rapid PS modules development.


## Install:

```powershell
PS> Install-Module DevTools
```

When developing the Powershell modules we need to test them, in order to do this,<br>
they should be installed in the system.

The easiest way to install the module - is to copy its contents to the PS modules directory or to<br>
create a `junction link` to it.

By default, the user's modules directory (let's call it UserScope) is located at:<br>
`C:\Users\{UserName}\Documents\WindowsPowerShell\Modules`

In order to these tools to work the project, should have the following structure:

```
+ ProjectName
  + Tests
    - ProjectName.Test.ps1
  - ProjectName.psm1
  - ProjectName.psd1
  - README.md
```

## Core Features:

| Command   | Description |
| --------- | ----------- |
Cleanup     | Remove project and it's dependencies from the UserScope
Shortcuts   | Create shortcuts to the project and it's dependencies in the UserScope
Copy        | Syncronize/Copy the project and it's dependencies to the UserScope
BumpVersion | Update project version.
Publish     | Publish project to PowerShell gallery
Deploy      | Update the project version and deploy it to PowerShell gallery

## Config
Use `$env:USERPROFILE` to find current profile location.

Set `projectsPath` to the directory where store the developed modules and their dependencies

In order to deploy to PowerShell Gallery you'll need to save your API key<br>
in the User's Profile: Create the file: `dev_tools_config.psd1`

```
@{
    projectsPath = 'D:\User\Development\OpenSource\Current\Powershell'
    apiKey = '000000000-0000-0000-0000-000000000000'
}
```

## Dependencies:

Dependencies are the modules including the project itself, that should be provisioned<br>
to UserScope. All the modules should be located in the same root folder:<br>
If the dependency module is already installed in the system you can skip it by setting `deploy = $false`

to configure the dependencies add the following section in the module's psd1 `ModuleName.psd1`

``` Powershell
DevTools = @{
    Dependencies = (
        @{
            deploy = $false
            name = 'ColoredText'
        }
    )
}
)
```

## Usage:

| Parameter | Description |
| --------- | ----------- |
-Project    | Project Name
-Action     | Actions from the aforementioned table.

The DevTools module is pretty smart! it has sophisticated autocompletion functionality.

The parameters are positional, so no need to specify them, just hit the "tab" for the autocompletion!

**Notice that the parameters order is different:**
In project directory, it is:
- `-Action`  Default action `[DevTools.Action]::Development`
- `-Project` Default to current project.

Everywhere else it's swapped for convenience reasons:
- `-Project` Mandatory!
- `-Action`  Default action `[DevTools.Action]::Development`

```shell
# If you are in a project directory just call:
cd SomeModule
dt Cleanup
dt Shortcuts
dt Deploy
# etc.
# If being in project directory you want to manipulate another 
# project add the project name as the second parameter:
dt BumpVersion AnotherProject
dt Cleanup AnotherProject

# any other folder
cd ..
dt SomeModule Deploy
dt SomeModule Shortcuts
```
If you want to implement your own automation script with the DevTools functionality,<br>
use the [DevTools.ps1](Tests/DevTools.ps1) as an example.<br>
The custom DevTools script sould be located at `ProjectName\Tests\DevTools.ps1`

## API
Brief explanation of the core API:

### Next Version:

`$version.next([DevTools.VersionComponent]::Build)` Will increment the specified part of the version by one.<br>
You can control which part to increment or set the new version manually.

```
# {Major}.{Minor}.{Build}
# [DevTools.VersionComponent]::Major
# [DevTools.VersionComponent]::Minor
# [DevTools.VersionComponent]::Build
$nextVersion = $version.next([DevTools.VersionComponent]::Build)
```
## entryPoint:

 After the test environment is ready, the script will launch a:<br>
`ProjectName\Tests\ProjectName.Test.ps1`<br>
In this file, you can do whatever you want to test and debug your app.

So the simple deploy script could look like this:

```powershell
using module DevTools

param ($action = [DevTools.Action]::Development)

$provision = [DevTools.ProvisionManager]@{ action = $action; root = $PSScriptRoot }
$version = [DevTools.VersionManager]@{ psd = $provision.psd }

$provision.dependencies = (
@{
    deploy = $true
    name = $provision.projectName
}
)

$provision.report('Version:{0}' -f [String]$version.version)
$provision.report('Action:{0}' -f $provision.action)

$nextVersion = $version.next([DevTools.VersionComponent]::Build)

switch ($provision.action)
{
    ([DevTools.Action]::Cleanup) { $provision.cleanup() }
    ([DevTools.Action]::Shortcuts) { $provision.shortcuts() }
    ([DevTools.Action]::Copy) { $provision.copy() }
    ([DevTools.Action]::BumpVersion) { $provision.bumpVersion($version, $nextVersion) }
    ([DevTools.Action]::Publish) { $provision.publish() }
    ([DevTools.Action]::Deploy)
    {
        $provision.bumpVersion($version, $nextVersion)
        $provision.publish()
    }
    default { }
}

if ($provision.action -ne [DevTools.Action]::Development) { return }

$provision.report('The Test Environment is redy.')

. $provision.entryPoint
```

## Execution:

There is no need to enter the entire word for the `Action` modifier.<br>
The tools will try to cast the type automatically from the partial keyword!

```shell
powershell -NoProfile .\Tests\DevTools.ps1
powershell -NoProfile .\Tests\DevTools.ps1 -Action Development
powershell -NoProfile .\Tests\DevTools.ps1 -Action Shortcuts
```

[psgallery-badge]: https://img.shields.io/badge/PowerShell_Gallery-1.0.4-green.svg
[psgallery-status]: https://www.powershellgallery.com/packages/DevTools/1.0.4
