# <img src="/Docs/Logo/logo.png" alt="Logo" width="48" align="left"/>  DevTools

[![Appveyor Badge][appveyor-badge]][appveyor-status]
[![Powershellgallery Badge][psgallery-badge]][psgallery-status]
[![GitHub Release Badge][release-badge]][release-status]
[![WMF Badge][wmf-badge]][wmf-status]
[![StrictMode Badge][strictmode-badge]][strictmode-status]
[![Discord Badge][discord-badge]][discord-status]
[![Downloads Badge][downloads-badge]][downloads-status]
[![Requirements Badge][requirements-badge]][requirements-status]


## UNDER DEVELOPMENT - lots of new features are coming


The main goal of `DevTools` is to streamline the PoweSell modules development, and make it as simple as possible.

## Features:

- Publish modules to PowerShell Gallery.
- Deploy and run tests on AppVeyor.
- Super easy modules development workflow.
- Install Modules to local environment.
- Test modules within the CurrentUser scope.
- Update Module version and badges.
- Continuous Integration.
- Implemented with the latest powershell 5 features (Classes, Enums, etc.).
- Fully adjustable.
- Tab completion in ISE and Console.
- Lots of syntactic sugar.
- Advanced API with strong typing, inheritance and extensibility.

## Install:

```powershell
PS> Install-Module DevTools
```

## Config
Use `$env:USERPROFILE` to find the current profile location.<br>
It should look like: `C:\Users\{UserName}`.

Create the config file in the user's profile: `C:\Users\{UserName}\dev_tools_config.psd1`

Set `projectsPath` to the directory where you store all of the developed modules.<br>
Set `apiKey` to your PowerShell Gallery API key

```
@{
projectsPath = 'D:\MyModules'
apiKey = '000000000-0000-0000-0000-000000000000'
}
```

## Workflow

```shell
# Create a GitHub repository "ProjectName" and clone it to "projectsPath"
ps> cd D:\MyModules
ps> git clone git@github.com:{user}/{ProjectName}.git

# Generate a new "dummy" PS Module with unique GUID.
ps> dt -GenerateProject ProjectName

# Add the module to the CurrentUser scope
# The project will behave like it's installed in the system,
# and any change you make will be immediately propagated.
ps> dt ProjectName Install
```

That's it, the project is now ready for development.

```
# Run the project's tests locally.
ps> dt ProjectName

# Commit and Push the changes to GitHub.
# If you connected your project's repository to AppVeyor, the `push` will trigger the AppVeyor build.
ps> git add .
ps> git commit -m "Test on AppVeyor"
ps> git push
```

After some tests, we are ready to release the project to the world.

The `Release` task will:
- Increment the module version.
- Update the necessary files.
- `Commit` the following changes.
- Create a new annotated `release tag`.
- Deploy the `release` to the PowerShell Gallery.

After you push the release to `GitHub`, it will trigger two `AppVeyor` builds,<br>
one to test the `master`, and the other to deploy the required artifacts back to GitHub.

It's a matter of taste whether to handle the PS Gallery deployment, locally or during the AppVeyor build. With DevTools it could be done either way, but as PS Gallery doesn't have rollbacks support, I prefer to do the publishing locally in order to immediately see all the related output. Anyway by the time we do the release, the module should be already tested both locally and on AppVeyor.

```shell
dt release

# --follow-tags key is mandatory to trigger the release build!
git push --follow-tags
```

Projects using `DevTools`:
- [Parser](https://github.com/g8tguy/Parser).
- [Debug](https://github.com/g8tguy/Debug).
- Well, pretty much all of my projects are developed with `DevTools`

When developing Powershell modules we need to test them, in order to do this,<br>
they should be installed in the system.

The easiest way to install the module - is to copy its contents to the PS modules directory or to<br>
create a `junction link` to it.

By default, the user's modules directory (let's call it CurrentUser scope) is located at:<br>
`C:\Users\{UserName}\Documents\WindowsPowerShell\Modules`

In order to these tools to work the project, should have the following minimal structure:

```
+ ProjectName
+ Tests
- EntyPoint.ps1
- ProjectName.psm1
- ProjectName.psd1
- README.md
```
## Actions - Tasks:

| Action    | Description |
| --------- | ----------- |
Cleanup     | Remove the project and it's dependencies from the `CurrentUser` scope
Install     | Create shortcuts to the project and it's dependencies in the `CurrentUser` scope
CopyToCurrentUserModules | Syncronize/Copy the project and it's dependencies to the `CurrentUser` scope
BumpVersion | Update project version.
Publish     | Publish project to PowerShell gallery
Deploy      | Update the project version and deploy it to PowerShell gallery
Build       | Create the next release and push it to AppVeyor artifacts.
Release     | Update version, `add` and `commit` version update to `Git`, Create `Release Tag`, publish the next release to PowerShell gallery.

## Usage:

| Parameter    | Description |
| ------------ | ----------- |
-Project       | Project Name
-Action        | Actions from the aforementioned table.
-VersionType   | `{Major}.{Minor}.{Build}` By default, the tools will increment the `Build` part of<br> the version, but you can easily change that with this optional parameter.
-CustomVersion | This parameter could be used to override the current version.
-NoPublish     | Skip the publishing stage during the `Release` Action.

The `DevTools` module is pretty smart! it has sophisticated autocompletion functionality.

The parameters are positional, so no need to specify them, just hit the "tab" for the autocompletion!

**Notice that the parameters order is different:**
In project directory, it is:
- `-Action`  Default action `[DevTools.Action]::Development`
- `-Project` Default to current project.

Everywhere else it's swapped for convenience reasons:
- `-Project` Mandatory!
- `-Action`  Default action `[DevTools.Action]::Development`

```shell
# If you are in the project directory just call:
cd SomeModule
dt # starts the tests
dt Test
dt Install
dt Release
dt Release Major
dt Release -CustomVersion 1.1.0
dt Cleanup
# etc.

# If, while being inside the project directory you'll want to manipulate another
# project - add that project name as the second parameter:
dt BumpVersion AnotherProject
dt Cleanup AnotherProject

# Any other folder:
cd ..
dt SomeModule Release
dt SomeModule Install
dt SomeModule Release Major
dt SomeModule Release -CustomVersion 1.1.0
```
## Dependencies: [DEPRECATED]

> It's still there and functional, but instead just use `DevTools` to manage each module separately!
So, there is no need to modify the project `psd` file any more!

Dependencies are the modules including the project itself, that should be provisioned<br>
to CurrentUser scope. All the modules should be located in the same root folder:<br>
If the dependency module is already installed in the system you can skip it by setting `deploy = $false`

to configure the dependencies add the following data to the module's `PrivateData` section psd1 `ModuleName.psd1`

``` Powershell
PrivateData = @{
DevTools = @{
Dependencies = (
@{
deploy = $false
name = 'ColoredText'
}
)
}
}
```

## API

Brief explanation of the core API:

If you want to implement your own automation script with the `DevTools` functionality,<br>
use the [API.ps1](Examples/API.ps1) as an example.<br>

The custom `DevTools` script sould be located at `ProjectName\{whatever}\{whatever}.ps1`

The `devtools` API is very powerful, you can get the basics by reviewing the `process` section of [DevTools.psm1](DevTools.psm1)

### Entry Point:

After the test environment is ready, the script will launch a:<br>
`ProjectName\Tests\EntyPoint.ps1`<br>
In this file, you can do whatever you want to test and debug your app.

So the simple custom deployment script could look like this:

```powershell
$script
```

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


### Custom Script Execution:

There is no need to enter the entire word for the `Action` modifier.<br>
The tools will try to cast the type automatically from the partial keyword!

```shell
powershell -NoProfile .\{whatever}\{whatever}.ps1
powershell -NoProfile .\{whatever}\{whatever}.ps1 -Action Test
powershell -NoProfile .\{whatever}\{whatever}.ps1 -Action Install
```



[appveyor-badge]: https://ci.appveyor.com/api/projects/status/github/g8tguy/DevTools?svg=true
[appveyor-status]: https://ci.appveyor.com/project/g8tguy/devtools

[psgallery-badge]: https://cdn.rawgit.com/g8tguy/DevTools/master/Docs/Badges/ps-gallery-1.1.8.svg
[psgallery-status]: https://www.powershellgallery.com/packages/DevTools/1.1.8

[release-badge]: https://cdn.rawgit.com/g8tguy/DevTools/master/Docs/Badges/release.svg
[release-status]: https://github.com/g8tguy/DevTools/releases/latest

[wmf-badge]: https://cdn.rawgit.com/g8tguy/DevTools/master/Docs/Badges/wmf.svg
[wmf-status]: https://msdn.microsoft.com/en-us/powershell/wmf/readme

[strictmode-badge]: https://cdn.rawgit.com/g8tguy/DevTools/master/Docs/Badges/strictmode.svg
[strictmode-status]: https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/set-strictmode

[discord-badge]: https://cdn.rawgit.com/g8tguy/DevTools/master/Docs/Badges/discord-chat.svg
[discord-status]: https://discord.gg/qQAmdDK

[downloads-badge]: https://cdn.rawgit.com/g8tguy/DevTools/master/Docs/Badges/downloads136.svg
[downloads-status]: https://www.powershellgallery.com/packages/DevTools

[requirements-badge]: https://cdn.rawgit.com/g8tguy/DevTools/master/Docs/Badges/req-false.svg
[requirements-status]: https://github.com/g8tguy/DevTools/blob/master/DevTools.psd1
