function Test-AdbWifiConnection {

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys wifi" -Verbose:$VerbosePreference `
            | Select-Object -First 1 `
            | Select-String -Pattern "Wi-Fi is (enabled|disabled)" -AllMatches `
            | ForEach-Object {
                $rawWifiEnabled = $_.Matches.Groups[1].Value
                switch ($rawWifiEnabled) {
                    "enabled" { $true }
                    "disabled" { $false }
                    default { Write-Error "Unexpected Wi-Fi status of '$rawWifiEnabled' in device with id '$id'" }
                }
            }
        }
    }
}
