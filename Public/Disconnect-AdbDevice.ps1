function Disconnect-AdbDevice {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [ValidatePattern('\b(?:(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\b')]
        [Parameter(Mandatory)]
        [string] $IpAddress,

        [Parameter(Mandatory)]
        [int] $Port
    )

    Invoke-AdbExpression -NoDevice -Command "disconnect ""$IpAddress`:$Port""" -Verbose:$VerbosePreference
}
