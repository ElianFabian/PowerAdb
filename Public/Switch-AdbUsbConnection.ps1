function Switch-AdbUsbConnection {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "usb" -Verbose:$VerbosePreference

            $ipAdress = Get-AdbLocalNetworkIp -DeviceId $id -Wait -Verbose:$false
            # To remove it from the list of connected devices (it's not immediately removed)
            Disconnect-AdbDevice -IpAddress $ipAdress -Port 5555 -Verbose:$VerbosePreference
        }
    }
}
