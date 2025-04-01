function Get-AdbNetConnectionProfileName {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command 'shell dumpsys netstats' -Verbose:$VerbosePreference `
            | Select-String -Pattern 'iface=wlan.*networkId="(.+)"'
            | Select-Object -First 1 `
            | ForEach-Object { $_.Matches[0].Groups[1].Value }
        }
    }
}
