function Disconnect-AdbDevice {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string[]] $IpAddress,

        [Parameter(Mandatory)]
        [int] $Port
    )

    process {
        foreach ($ip in $IpAddress) {
            if ($PSCmdlet.ShouldProcess("adb disconnect $ip`:$Port", "", "Disconnect-AdbDevice")) {
                adb disconnect "$ip`:$Port"
            }
        }
    }
}
