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
                Write-Error "'adb shell input keycombination' is not available for api levels lower or equal to 30. Device id: '$id', api level: '$apiLevel'"
                continue
            }
            if ($apiLevel -le 33) {
                Write-Error "'adb shell input keycombination' is available for api levels [31, 32, 33] (the command exists but it doesn't seem to work properly). Device id: '$id', api level: '$apiLevel'"
                continue
            }
            Invoke-AdbExpression -DeviceId $id -Command "shell input keycombination $($KeyCodes | ForEach-Object { "KEYCODE_$_" })" -Verbose:$VerbosePreference | Out-Null
        }
    }
}
