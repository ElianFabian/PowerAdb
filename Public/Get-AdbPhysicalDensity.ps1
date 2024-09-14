function Get-AdbPhysicalDensity {

    [CmdletBinding()]
    [OutputType([uint32[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    begin {
        # Length of 'Physical density: '
        $physicalDensityStrLength = 18
    }

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 18) {
                Write-Error "Physical density is not supported for device with id '$id' with API level of '$apiLevel'. Only API levels 18 and above are supported."
                continue
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell wm density" -Verbose:$VerbosePreference `
            | Out-String -Stream `
            | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } `
            | ForEach-Object {
                [uint32] $_.Substring($physicalDensityStrLength)
            }
        }
    }
}
