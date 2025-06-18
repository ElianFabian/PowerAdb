function Disconnect-AdbDevice {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $IpAddress,

        [Parameter(Mandatory)]
        [int] $Port
    )

    Invoke-AdbExpression -Command "disconnect ""$IpAddress`:$Port""" -IgnoreExecutionCheck -Verbose:$VerbosePreference
}
