function Connect-AdbDevice2 {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string[]] $DeviceId,

        [switch] $Force
    )

    process {
        foreach ($id in $DeviceId) {
            $isWirelessDebuggingEnabled = Get-AdbSetting -DeviceId $id -Namespace Global -Key adb_wifi_enabled -Verbose:$false
            if ($isWirelessDebuggingEnabled -eq 0 -and -not $Force) {
                Write-Error "Wireless debugging is not enabled on device $id. Use -Force to enable it."
                return
            }

            $currentPcWifiName = Get-NetConnectionProfile | Select-Object -ExpandProperty Name
            $deviceWifiName = Get-AdbNetConnectionProfileName -DeviceId $id -Verbose:$false
            if ($deviceWifiName -cne $currentPcWifiName) {
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
