# DevTools

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
    - DevTools.ps1
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

## Dependencies:

Dependencies are the modules including the project itself, that should be provisioned<br>
to UserScope. All the modules should be located in the same root folder:<br>
If the dependency module already installed in the system you can skip it by setting `deploy = $false`

``` Powershell
$provision.dependencies = (
@{
    deploy = $true
    name = $provision.projectName
},
@{
    deploy = $false
    name = 'ColoredText'
}
)
```

## Next Version:

`$version.next([VersionComponent]::Build)` Will increment the specified part of the version by one.<br>
You can control which part to increment or set the new version manually.

```
# {Major}.{Minor}.{Build}
# [VersionComponent]::Major 
# [VersionComponent]::Minor
# [VersionComponent]::Build
$nextVersion = $version.next([VersionComponent]::Build)
```
## entryPoint:
 
 After the test environment is ready, the script will launch a:<br>
`ProjectName\Tests\ProjectName.Test.ps1`<br>
In this file, you can do whatever you want to test and debug your app.

So the simple deploy script could look like this:

```powershell
using module DevTools

param ($action = [Action]::Development)

$provision = [DevTools.ProvisionManager]@{ action = $action; root = $PSScriptRoot}
$version = [DevTools.VersionManager]@{ psd = $provision.psd }

$provision.dependencies = (
@{
    deploy = $true
    name = $provision.projectName
},
@{
    deploy = $false
    name = 'ColoredText'
}
)

$provision.report('Version:{0}' -f [String]$version.version)
$provision.report('Action:{0}' -f $provision.action)

$nextVersion = $version.next([VersionComponent]::Build)

switch ($provision.action)
{
    ([Action]::Cleanup) { $provision.cleanup() }
    ([Action]::Shortcuts) { $provision.shortcuts() }
    ([Action]::Copy) { $provision.copy() }
    ([Action]::BumpVersion) { $provision.bumpVersion($version, $nextVersion) }
    ([Action]::Publish) { $provision.publish() }
    ([Action]::Deploy)
    {
        $provision.bumpVersion($version, $nextVersion)
        $provision.publish()
    }
    default { }
}

if ($provision.action -ne [Action]::Development) { return }

$provision.report('The Test Environment is redy.')

. $provision.entryPoint

```
