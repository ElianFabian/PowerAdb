function Start-AdbServer {

    [CmdletBinding(SupportsShouldProcess)]
    param ()

    Invoke-AdbExpression -Command "start-server" -Verbose:$VerbosePreference
}
