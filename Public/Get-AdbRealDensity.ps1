function Get-AdbRealDensity {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 17

    $apiLevel = Get-AdbApiLevel -SerialNumber $SerialNumber -Verbose:$false

    $pattern = if ($apiLevel -ge 30) {
        'xDpi=(-?\d+(\.\d+)?)'
    }
    else {
        '(-?\d+(\.\d+)?) dpi'
    }

    return Get-AdbServiceDump -SerialNumber $SerialNumber -Name 'display' -Verbose:$VerbosePreference `
    | Select-String -Pattern $pattern `
    | ForEach-Object { $_.Matches } `
    | Select-Object -First 1 `
    | ForEach-Object { [int] $_.Groups[1].Value }
}
