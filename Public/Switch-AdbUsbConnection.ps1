function Switch-AdbUsbConnection {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId
    )

    Invoke-AdbExpression -DeviceId $DeviceId -Command "usb" -Verbose:$VerbosePreference

    $ipAdress = Get-AdbLocalNetworkIp -DeviceId $DeviceId -Wait -Verbose:$false
    # To remove it from the list of connected devices (it's not immediately removed)
    Disconnect-AdbDevice -IpAddress $ipAdress -Port 5555 -Verbose:$VerbosePreference
}
