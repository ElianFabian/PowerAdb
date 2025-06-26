function Connect-AdbDevice2 {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [switch] $Force
    )

    if (Test-AdbEmulator -SerialNumber $SerialNumber) {
        Write-Error "Cannot connect to an emulator using this Connect-AdbDevice2" -Category InvalidOperation -ErrorAction Stop
    }

    # The adb_wifi_enabled has the following values:
    # 0 - Wireless debugging is disabled
    # 1 - Wireless debugging is enabled
    # 'null' - Wireless debugging is enabled (at least on the tests made)
    $isWirelessDebuggingEnabled = Get-AdbSetting -SerialNumber $SerialNumber -Namespace global -Name 'adb_wifi_enabled' -Verbose:$false
    if ($isWirelessDebuggingEnabled -eq 0 -and -not $Force) {
        Write-Error "Wireless debugging is not enabled on device $SerialNumber. Use -Force to enable it."
        continue
    }

    if (-not (Test-AdbInternetConnection -SerialNumber $SerialNumber -Verbose:$false)) {
        Write-Error "Device '$SerialNumber' has no internet connection. Please check your connection."
        continue
    }

    ### EDIT: Since Get-NetConnectionProfile doesn't return the correct name of the Wi-Fi
    # we decide to omit this check for now.

    # WORKAROUND: We check if the computer's Wi-Fi name contains the device's Wi-Fi name
    # since the name returned by Get-NetConnectionProfile may contain a number at the end.
    # $currentPcWifiName = Get-NetConnectionProfile | Select-Object -ExpandProperty Name
    # $deviceWifiName = Get-AdbNetConnectionProfileName -SerialNumber $SerialNumber -Verbose:$false
    # if (-not $currentPcWifiName.Contains($deviceWifiName)) {
    #     Write-Error "Device '$SerialNumber' is connected to a different Wi-Fi network. PC: '$currentPcWifiName', Device: '$deviceWifiName'"
    #     continue
    # }

    if ($Force -and $isWirelessDebuggingEnabled -ne 1 -and $isWirelessDebuggingEnabled -ne 'null') {
        Set-AdbSetting -SerialNumber $SerialNumber -Namespace global -Name 'adb_wifi_enabled' -Value 1 -Verbose:$false
    }

    $ipAdress = Get-AdbLocalNetworkIp -SerialNumber $SerialNumber -Wait -Verbose:$false
    Start-AdbTcpIp -SerialNumber $SerialNumber -Port 5555 -Verbose:$VerbosePreference
    Connect-AdbDevice -IpAddress $ipAdress -Port 5555 -Verbose:$VerbosePreference
}

# TODO: we could try to use this to check if the device and the computer are on the same network

# Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -eq 'Wi-Fi' } | ForEach-Object { "$($_.IPAddress)-$($_.PrefixLength)" }

# adb shell ip route
# 192.168.1.0/24 dev wlan0 proto kernel scope link src 192.168.1.102


# function Get-NetworkAddress {
#     param(
#         [string]$ip,
#         [int]$prefixLength
#     )

#     $ipAddr = [System.Net.IPAddress]::Parse($ip)
#     $ipBytes = $ipAddr.GetAddressBytes()

#     # Crear la máscara
#     $maskBits = [Convert]::ToString(([math]::Pow(2, 32) - 1) - ([math]::Pow(2, 32 - $prefixLength) - 1), 2).PadLeft(32, '0')
#     $maskBytes = @()
#     for ($i = 0; $i -lt 4; $i++) {
#         $maskBytes += [Convert]::ToInt32($maskBits.Substring($i * 8, 8), 2)
#     }

#     # AND entre IP y máscara
#     $networkBytes = for ($i = 0; $i -lt 4; $i++) {
#         $ipBytes[$i] -band $maskBytes[$i]
#     }

#     return ($networkBytes -join ".") + "/$prefixLength"
# }

# # Ejemplo de uso
# Get-NetworkAddress -ip "192.168.1.130" -prefixLength 25  # Resultado: 192.168.1.128/25
