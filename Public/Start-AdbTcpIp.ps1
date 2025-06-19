function Start-AdbTcpIp {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [int] $Port
    )

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "tcpip $Port" -Verbose:$VerbosePreference
}
