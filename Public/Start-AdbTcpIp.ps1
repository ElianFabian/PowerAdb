function Start-AdbTcpIp {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [int] $Port
    )

    Invoke-AdbExpression -DeviceId $DeviceId -Command "tcpip $Port" -Verbose:$VerbosePreference
}
