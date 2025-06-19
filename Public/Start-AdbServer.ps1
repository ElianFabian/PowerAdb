function Start-AdbServer {

    [CmdletBinding(SupportsShouldProcess)]
    param ()

    try {
        Invoke-AdbExpression -Command "start-server" -IgnoreExecutionCheck -Verbose:$VerbosePreference
    }
    catch [AdbCommandException] {
        if ($_.Exception.Message.EndsWith('daemon started successfully')) {
            Write-Host $_.Exception.Message -ForegroundColor Green
            return
        }
        throw $_
    }
}
