function Start-AdbServer {

    [CmdletBinding(SupportsShouldProcess)]
    param ()

    Invoke-AdbExpression -NoDevice -Command "start-server" -Verbose:$VerbosePreference
}
