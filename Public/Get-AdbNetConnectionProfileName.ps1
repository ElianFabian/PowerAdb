function Get-AdbNetConnectionProfileName {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    Get-AdbServiceDump -DeviceId $DeviceId -Name 'netstats' -Verbose:$VerbosePreference `
    | Select-String -Pattern 'iface=wlan.*(networkId|wifiNetworkKey)="(?<name>.+)"' `
    | Select-Object -First 1 `
    | ForEach-Object { $_.Matches[0].Groups["name"].Value }
}
