function Switch-AdbUsbConnection {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber
    )

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "usb" -Verbose:$VerbosePreference

    $ipAdress = Get-AdbLocalNetworkIp -SerialNumber $SerialNumber -Wait -Verbose:$false
    # To remove it from the list of connected devices (it's not immediately removed)
    Disconnect-AdbDevice -IpAddress $ipAdress -Port 5555 -Verbose:$VerbosePreference
}
