function Connect-AdbDevice2 {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $isWirelessDebuggingEnabled = Get-AdbSetting -DeviceId $id -Namespace Global -Key adb_wifi_enabled -Verbose:$false
            if ($isWirelessDebuggingEnabled -eq 0) {
                Write-Error "Wireless debugging is not enabled on device $id."
                return
            }
            Start-AdbTcpIp -DeviceId $id -Port 5555 -Verbose:$VerbosePreference
            $ipAdress = Get-AdbLocalNetworkIp -DeviceId $id -Wait -Verbose:$false
            Connect-AdbDevice -IpAddress $ipAdress -Port 5555 -Verbose:$VerbosePreference
        }
    }
}
