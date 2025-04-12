function Get-AdbRealPhysicalDensity {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 17

    $apiLevel = Get-AdbApiLevel -DeviceId $DeviceId -Verbose:$false

    $pattern = if ($apiLevel -ge 30) {
        'xDpi=(-?\d+(\.\d+)?)'
    }
    else {
        '(-?\d+(\.\d+)?) dpi'
    }

    return Get-AdbServiceDump -DeviceId $DeviceId -Name 'display' -Verbose:$VerbosePreference `
    | Select-String -Pattern $pattern `
    | ForEach-Object { $_.Matches } `
    | Select-Object -First 1 `
    | ForEach-Object { [int] $_.Groups[1].Value }
}
