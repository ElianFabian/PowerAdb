function Connect-AdbDevice {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [ValidatePattern('\b(?:(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\b')]
        [Parameter(Mandatory)]
        [string] $IpAddress,

        [Parameter(Mandatory)]
        [int] $Port
    )

    if (Test-AdbEmulator -DeviceId $DeviceId) {
        Write-Error "Cannot connect to an emulator using this Connect-AdbDevice" -Category InvalidOperation -ErrorAction Stop
    }

    try {
        $result = Invoke-AdbExpression -Command "connect ""$IpAddress`:$Port""" -IgnoreExecutionCheck -Verbose:$VerbosePreference
        Write-Verbose $result
    }
    catch [AdbCommandException] {
        if ($_.Exception.Message.Contains('cannot connect to')) {
            Write-Error "Check that the device '$IpAddress`:$Port' is connected to the same network as your computer"
            throw $_
        }
    }
}
