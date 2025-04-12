function Connect-AdbDevice {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $IpAddress,

        [Parameter(Mandatory)]
        [int] $Port
    )

    if ($PSCmdlet.ShouldProcess("adb connect $IpAddress`:$Port", "", "Connect-AdbDevice")) {
        adb connect "$IpAddress`:$Port"
    }
}
