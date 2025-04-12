function Connect-AdbDevice2 {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $DeviceId,

        [switch] $Force
    )

    $isWirelessDebuggingEnabled = Get-AdbSetting -DeviceId $DeviceId -Namespace global -Key adb_wifi_enabled -Verbose:$false
    if ($isWirelessDebuggingEnabled -eq 0 -and -not $Force) {
        Write-Error "Wireless debugging is not enabled on device $DeviceId. Use -Force to enable it."
        continue
    }

    if (-not (Test-AdbWifi -DeviceId $DeviceId -Verbose:$false) -or -not (Test-AdbMobileData -DeviceId $DeviceId -Verbose:$false)) {
        Write-Error "Device '$DeviceId' has no internet connection. Please check your connection."
        continue
    }

    ### EDIT: Since Get-NetConnectionProfile doesn't return the correct name of the Wi-Fi
    # we decide to omit this check for now.

    # WORKAROUND: We check if the computer's Wi-Fi name contains the device's Wi-Fi name
    # since the name returned by Get-NetConnectionProfile may contain a number at the end.
    # $currentPcWifiName = Get-NetConnectionProfile | Select-Object -ExpandProperty Name
    # $deviceWifiName = Get-AdbNetConnectionProfileName -DeviceId $DeviceId -Verbose:$false
    # if (-not $currentPcWifiName.Contains($deviceWifiName)) {
    #     Write-Error "Device '$DeviceId' is connected to a different Wi-Fi network. PC: '$currentPcWifiName', Device: '$deviceWifiName'"
    #     continue
    # }

    Set-AdbSetting -DeviceId $DeviceId -Namespace global -Key 'adb_wifi_enabled' -Value 1 -Verbose:$false

    $ipAdress = Get-AdbLocalNetworkIp -DeviceId $DeviceId -Wait -Verbose:$false
    Start-AdbTcpIp -DeviceId $DeviceId -Port 5555 -Verbose:$VerbosePreference
    Connect-AdbDevice -IpAddress $ipAdress -Port 5555 -Verbose:$VerbosePreference
}
