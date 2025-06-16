function Start-AdbServer {

    [CmdletBinding(SupportsShouldProcess)]
    param ()

    Invoke-AdbExpression -Command "start-server" -IgnoreExecutionCheck -Verbose:$VerbosePreference
}
