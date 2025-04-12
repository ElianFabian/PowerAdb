function Test-AdbWifi {

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    Get-AdbServiceDump -DeviceId $DeviceId -Name 'wifi' -Verbose:$VerbosePreference `
    | Select-String -Pattern 'Wi-Fi is (enabled|disabled)' `
    | Select-Object -First 1 `
    | ForEach-Object {
        $rawWifiEnabled = $_.Matches[0].Groups[1].Value
        switch ($rawWifiEnabled) {
            'enabled' { $true }
            'disabled' { $false }
            default { Write-Error "Unexpected Wi-Fi status of '$rawWifiEnabled' in device with id '$id'" -ErrorAction Stop }
        }
    }
}

# This function probably could be also implemented using "adb shell settings get global wifi_on", but it is not available in API level 16 and below.
