function Connect-AdbDevice2 {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        # When empty, it will connect all devices that are offline
        [Parameter(ValueFromPipeline)]
        [string[]] $DeviceId,

        [switch] $Force
    )

    process {
        $devices = $DeviceId
        if ($DeviceId.Count -eq 0) {
            $devices = Get-AdbDevice `
            | Where-Object {
                $state = Get-AdbDeviceState -DeviceId $_ -Verbose:$false
                $state -eq 'offline'
            }
        }

        foreach ($id in $devices) {
            $isWirelessDebuggingEnabled = Get-AdbSetting -DeviceId $id -Namespace Global -Key adb_wifi_enabled -Verbose:$false
            if ($isWirelessDebuggingEnabled -eq 0 -and -not $Force) {
                Write-Error "Wireless debugging is not enabled on device $id. Use -Force to enable it."
                return
            }

            # WORKAROUND: We check if the computer's Wi-Fi name contains the device's Wi-Fi name
            # since the name returned by Get-NetConnectionProfile may contain a number at the end.
            $currentPcWifiName = Get-NetConnectionProfile | Select-Object -ExpandProperty Name
            $deviceWifiName = Get-AdbNetConnectionProfileName -DeviceId $id -Verbose:$false
            if (-not $currentPcWifiName.Contains($deviceWifiName)) {
                Write-Error "Device '$id' is connected to a different Wi-Fi network. PC: '$currentPcWifiName', Device: '$deviceWifiName'"
                return
            }

            Set-AdbSetting -DeviceId $id -Namespace Global -Key adb_wifi_enabled -Value 1 -Verbose:$false

            $ipAdress = Get-AdbLocalNetworkIp -DeviceId $id -Wait -Verbose:$false
            Start-AdbTcpIp -DeviceId $id -Port 5555 -Verbose:$VerbosePreference
            Connect-AdbDevice -IpAddress $ipAdress -Port 5555 -Verbose:$VerbosePreference
        }
    }
}
