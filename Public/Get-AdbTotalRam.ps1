function Get-AdbTotalRam {

    [CmdletBinding()]
    [OutputType([uint64])]
    param (
        [string] $SerialNumber
    )

    if (Test-CachedValue -SerialNumber $SerialNumber) {
        Get-CacheValue -SerialNumber $SerialNumber
    }
    else {
        $result = Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell cat /proc/meminfo" -Verbose:$VerbosePreference `
        | Select-String -Pattern "MemTotal:\s*(\d+)\skB" -AllMatches `
        | Select-Object -First 1 `
        | ForEach-Object { $_.Matches.Groups[1].Value } `
        | ForEach-Object { ([uint64] $_) * 1024 }

        Set-CacheValue -SerialNumber $SerialNumber -Value $result

        [uint64] $result
    }
}
