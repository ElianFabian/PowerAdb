function Get-AdbTotalRam {

    [CmdletBinding()]
    [OutputType([uint64])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $cachedTotalRam = Get-CacheValue -DeviceId $id -ErrorAction SilentlyContinue
            if ($null -ne $cachedTotalRam) {
                Write-Verbose "Get cached total RAM for device with id '$id'"
                [uint64] $cachedTotalRam
            }
            else {
                $result = Invoke-AdbExpression -DeviceId $id -Command "shell cat /proc/meminfo" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
                | Select-String -Pattern "MemTotal:\s*(\d+)\skB" -AllMatches `
                | Select-Object -First 1 `
                | ForEach-Object { $_.Matches.Groups[1].Value } `
                | ForEach-Object { ([uint64] $_) * 1024 }
                Set-CacheValue -DeviceId $id -Value $result
                [uint64] $result
            }
        }
    }
}
