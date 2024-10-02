function Get-AdbOverrideDensity {

    [CmdletBinding()]
    [OutputType([uint32[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 18) {
                Write-Error "Override density is not supported for device with id '$id' with API level of '$apiLevel'. Only API levels 18 and above are supported."
                continue
            }

            $values = Invoke-AdbExpression -DeviceId $id -Command "shell wm density" -Verbose:$VerbosePreference `
            | Out-String -Stream `
            | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } `
            | Select-String -Pattern 'Override density: (\d+)' -AllMatches `
            | ForEach-Object { [uint32] $_.Matches.Groups[1].Value }

            if (-not $values) {
                -1
            }
            else { $values }
        }
    }
}
