function Stop-AdbServer {

    [CmdletBinding(SupportsShouldProcess)]
    param ()

    Invoke-AdbExpression -Command "kill-server" -IgnoreExecutionCheck -Verbose:$VerbosePreference
}
