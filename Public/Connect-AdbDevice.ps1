function Connect-AdbDevice {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [ValidatePattern('\b(?:(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\b')]
        [Parameter(Mandatory)]
        [string] $IpAddress,

        [Parameter(Mandatory)]
        [int] $Port
    )

    try {
        Invoke-AdbExpression -NoDevice -Command "connect ""$IpAddress`:$Port""" -Verbose:$VerbosePreference
    }
    catch [AdbCommandException] {
        if ($_.Exception.Message.Contains('cannot connect to')) {
            Write-Error "Check that the device '$IpAddress`:$Port' is connected to the same network as your computer"
            throw $_
        }
    }
}
