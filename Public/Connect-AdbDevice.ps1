function Connect-AdbDevice {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $IpAddress,

        [Parameter(Mandatory)]
        [int] $Port
    )

    try {
        $result = Invoke-AdbExpression -Command "connect ""$IpAddress`:$Port""" -IgnoreExecutionCheck -Verbose:$VerbosePreference
        if ($result.StartsWith('cannot resolve host') -or $result.StartsWith('cannot connect to')) {
            Write-Error $result -ErrorAction Stop
        }
        Write-Verbose $result
    }
    catch [AdbCommandException] {
        if ($_.Exception.Message.Contains('cannot connect to')) {
            Write-Error "Check that the device '$IpAddress`:$Port' is connected to the same network as your computer"
            throw $_
        }
    }
}
