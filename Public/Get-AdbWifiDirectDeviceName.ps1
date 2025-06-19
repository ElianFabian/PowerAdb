function Get-AdbWifiDirectDeviceName {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    return Invoke-AdbExpression -SerialNumber $SerialNumber -Command 'shell dumpsys wifi' -Verbose:$VerbosePreference `
    | Where-Object { $_.StartsWith('wifi_p2p_device_name=')} `
    | Select-Object -First 1 `
    | ForEach-Object {
        $_.Replace('wifi_p2p_device_name=', '')
    }
}
