function Send-AdbKeyCombination {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [ValidateCount(2, [int]::MaxValue)]
        [Parameter(Mandatory)]
        [string[]] $KeyCodes
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = [uint32] (Get-AdbProperty -DeviceId $id -Name ro.build.version.sdk -Verbose:$false)
            if ($apiLevel -le 30) {
                Write-ApiLevelError -DeviceId $id -ApiLevelLessThan 30
                continue
            }
            Invoke-AdbExpression -DeviceId $id -Command "shell input keycombination $($KeyCodes | ForEach-Object { "KEYCODE_$_" })" -Verbose:$VerbosePreference | Out-Null
        }
    }
}
