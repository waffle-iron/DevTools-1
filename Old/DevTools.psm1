
[DynamicConfig]$script:devTools = $null

function Use-DevTools
{
    process
    {
        $moduleName, $actionType = $devTools.setProjectVariables($psBoundParameters)
        
        #  [IManager]$appVeyor = $devTools.appVeyorFactory()
        [IManager]$provision = $devTools.provisionFactory()
       # [IManager]$version = $devTools.versionFactory()
        #        [IManager]$module = $devTools.moduleFactory()
        #        [IManager]$badge = $devTools.badgeFactory()
        
        #$devTools.info($devTools.getTitle())
        
        #        $nextVersion = switch ([Boolean]$customVersion)
        #        {
        #            True { $customVersion }
        #            Default { $version.next($devTools.versionType) }
        #        }
        #        $badge.updateBadgs()
        #return
        
        switch ($actionType)
        {
            ([Action]::Install) { $provision.install() }
            
            #([Action]::GenerateProject) { $module.create() }
            
            #            ([Action]::Cleanup) { $provision.cleanup() }
            #            ([Action]::CopyToCurrentUserModules) { $provision.copy() }
            #            ([Action]::BumpVersion) { $provision.bumpVersion($version, $nextVersion) }
            #            ([Action]::Publish) { $provision.publish() }
            #            ([Action]::Deploy)
            #            {
            #                $provision.bumpVersion($version, $nextVersion)
            #                $provision.publish()
            #            }
            #            ([Action]::Build)
            #            {
            #                if ($env:APPVEYOR_REPO_TAG -eq $false)
            #                {
            #                    $devTools.warning('Task [Build] is not allowed on {0}!' -f $env:APPVEYOR_REPO_BRANCH)
            #                    break
            #                }
            #                $appVeyor.pushArtifact($version.version)
            #            }
            #            ([Action]::Release)
            #            {
            #                while ($choice -notmatch '[y|n]')
            #                {
            #                    Read-Host -OutVariable choice `
            #                              -Prompt "Publish The Next [$nextVersion] Release, Are You Shure?(Y/N)"
            #                }
            #                
            #                if ($choice -eq 'n') { break }
            #                
            #                $provision.bumpVersion($version, $nextVersion)
            #                $provision.gitCommitVersionChange($nextVersion)
            #                $provision.gitTag($nextVersion)
            #                
            #                if ($noPublish.isPresent) { break }
            #                
            #                $provision.publish()
            #            }
            ([Action]::Test)
            {
                #                if ($env:APPVEYOR_REPO_TAG -eq $true)
                #                {
                #                    $devTools.warning('Task [Test] is not allowed on Tag branches!')
                #                    return
                #                }
                
                if ($WhatIf) { break }
                
                & $provision.entryPoint #Invoke-Expression
                
            }
            default { }
        }
    }
}

