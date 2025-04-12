function Get-AdbTotalRam {

    [CmdletBinding()]
    [OutputType([uint64])]
    param (
        [string] $DeviceId
    )

    if (Test-CachedValue -DeviceId $DeviceId) {
        Get-CacheValue -DeviceId $DeviceId
    }
    else {
        $result = Invoke-AdbExpression -DeviceId $DeviceId -Command "shell cat /proc/meminfo" -Verbose:$VerbosePreference `
        | Select-String -Pattern "MemTotal:\s*(\d+)\skB" -AllMatches `
        | Select-Object -First 1 `
        | ForEach-Object { $_.Matches.Groups[1].Value } `
        | ForEach-Object { ([uint64] $_) * 1024 }

        Set-CacheValue -DeviceId $DeviceId -Value $result

        [uint64] $result
    }
}
