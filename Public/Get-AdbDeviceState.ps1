function Get-AdbDeviceState {

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string] $DeviceId
    )

    try {
        return Invoke-AdbExpression -DeviceId $DeviceId -Command "get-state" -Verbose:$VerbosePreference
    }
    catch [AdbCommandException] {
        if ($_.Exception.Message -eq 'error: device offline') {
            return 'offline'
        }
        throw $_
    }
}
