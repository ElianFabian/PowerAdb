function Get-AdbAvailableRam {

    [CmdletBinding()]
    [OutputType([uint64])]
    param (
        [string] $DeviceId
    )

    Invoke-AdbExpression -DeviceId $DeviceId -Command "shell cat /proc/meminfo" -Verbose:$VerbosePreference `
    | Select-String -Pattern "MemAvailable:\s*(\d+)\skB" -AllMatches `
    | Select-Object -First 1 `
    | ForEach-Object { $_.Matches.Groups[1].Value } `
    | ForEach-Object { ([uint64] $_) * 1024 }
}
