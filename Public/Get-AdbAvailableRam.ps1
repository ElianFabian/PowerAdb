function Get-AdbAvailableRam {

    [CmdletBinding()]
    [OutputType([uint64])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell cat /proc/meminfo" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
            | Select-String -Pattern "MemAvailable:\s*(\d+)\skB" -AllMatches `
            | Select-Object -First 1 `
            | ForEach-Object { $_.Matches.Groups[1].Value } `
            | ForEach-Object { ([uint64] $_) * 1024 }
        }
    }
}
