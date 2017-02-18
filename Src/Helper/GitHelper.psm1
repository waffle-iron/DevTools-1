#[Void]gitCommand([Array]$arguments)
#{
#    $ps = new-object Process
#    $ps.StartInfo.Filename = 'git'
#    
#    $ps.startInfo.arguments = $arguments
#    
#    $ps.StartInfo.RedirectStandardOutput = $True
#    $ps.StartInfo.RedirectStandardError = $true
#    $ps.StartInfo.UseShellExecute = $false
#    $ps.Start()
#    $ps.WaitForExit()
#    $output = $ps.StandardOutput.ReadToEnd().trim()
#    $error = $ps.StandardError.ReadToEnd().trim()
#    
#    if ([Boolean]$output) { $this.devTools.warning([Environment]::NewLine + $output) }
#    if ([Boolean]$error) { $this.devTools.error([Environment]::NewLine + $error) }
#}
#
#[Void]gitCommitVersionChange($version)
#{
#    $message = 'Version Bump {0}' -f $version
#    
#    $this.gitCommand((
#            ('-C "{0}"' -f $this.project.FullName),
#            'commit  -a -m "{0}"' -f $message
#        ))
#}
#
#[Void]gitTag($version)
#{
#    $desciption = '{0} release {1}.' -f $this.projectName, $version
#    
#    $this.gitCommand((
#            ('-C "{0}"' -f $this.project.FullName),
#            'tag  -a -m "{0}" "{1}"' -f $desciption, $version
#        ))
#}
#}