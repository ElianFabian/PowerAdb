function Get-AdbDeviceWifiMacAddress {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    return Get-AdbServiceDump -DeviceId $DeviceId -Name 'wifi' -Verbose:$VerbosePreference `
    | Where-Object { $_.StartsWith('wifi_sta_factory_mac_address=') } `
    | Select-Object -First 1 `
    | ForEach-Object {
        $_.Replace('wifi_sta_factory_mac_address=', '')
    }
}
