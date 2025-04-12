function Disconnect-AdbDevice {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $IpAddress,

        [Parameter(Mandatory)]
        [int] $Port
    )

    if ($PSCmdlet.ShouldProcess("adb disconnect $IpAddress`:$Port", "", 'Disconnect-AdbDevice')) {
        adb disconnect "$IpAddress`:$Port"
    }
}
