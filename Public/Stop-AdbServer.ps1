function Stop-AdbServer {
    
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    Invoke-AdbExpression -Command "kill-server" -Verbose:$VerbosePreference
}
