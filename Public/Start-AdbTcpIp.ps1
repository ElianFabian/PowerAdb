function Start-AdbTcpIp {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [int] $Port
    )

    process {
        foreach ($id in $DeviceId) {
            if ($PSCmdlet.ShouldProcess("adb -s $id tcpip $Port", "", "Start-AdbTcpIp")) {
                adb -s $id tcpip $Port
            }
        }
    }
}
