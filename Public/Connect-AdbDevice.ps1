function Connect-AdbDevice {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string[]] $IpAddress,

        [Parameter(Mandatory)]
        [int] $Port
    )

    process {
        foreach ($ip in $IpAddress) {
            if ($PSCmdlet.ShouldProcess("adb connect $ip`:$Port", "", "Connect-AdbDevice")) {
                adb connect "$ip`:$Port"
            }
        }
    }
}
