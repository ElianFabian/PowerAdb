function Get-AdbNetConnectionProfileName {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    Get-AdbServiceDump -SerialNumber $SerialNumber -Name 'netstats' -Verbose:$VerbosePreference `
    | Select-String -Pattern 'iface=wlan.*(networkId|wifiNetworkKey)="(?<name>.+)"' `
    | Select-Object -First 1 `
    | ForEach-Object { $_.Matches[0].Groups["name"].Value }
}
