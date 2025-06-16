function Connect-AdbDevice2 {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [switch] $Force
    )

    if (Test-AdbEmulator -DeviceId $DeviceId) {
        Write-Error "Cannot connect to an emulator using this Connect-AdbDevice2" -Category InvalidOperation -ErrorAction Stop
    }

    # The adb_wifi_enabled has the following values:
    # 0 - Wireless debugging is disabled
    # 1 - Wireless debugging is enabled
    # 'null' - Wireless debugging is enabled (at least)
    $isWirelessDebuggingEnabled = Get-AdbSetting -DeviceId $DeviceId -Namespace global -Name 'adb_wifi_enabled' -Verbose:$false
    if ($isWirelessDebuggingEnabled -eq 0 -and -not $Force) {
        Write-Error "Wireless debugging is not enabled on device $DeviceId. Use -Force to enable it."
        continue
    }

    if (-not (Test-AdbInternetConnection -DeviceId $DeviceId -Verbose:$false)) {
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

    if ($Force -and $isWirelessDebuggingEnabled -ne 1 -and $isWirelessDebuggingEnabled -ne 'null') {
        Set-AdbSetting -DeviceId $DeviceId -Namespace global -Name 'adb_wifi_enabled' -Value 1 -Verbose:$false
    }

    $ipAdress = Get-AdbLocalNetworkIp -DeviceId $DeviceId -Wait -Verbose:$false
    Start-AdbTcpIp -DeviceId $DeviceId -Port 5555 -Verbose:$VerbosePreference
    Connect-AdbDevice -IpAddress $ipAdress -Port 5555 -Verbose:$VerbosePreference

    # We could return true or false to indicate success or failure
}
