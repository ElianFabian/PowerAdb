function Stop-AdbServer {

    [CmdletBinding(SupportsShouldProcess)]
    param ()

    Invoke-AdbExpression -NoDevice -Command "kill-server" -Verbose:$VerbosePreference
}
