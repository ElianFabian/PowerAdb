function Send-AdbKeyCombination {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [ValidateCount(2, [int]::MaxValue)]
        [Parameter(Mandatory)]
        [string[]] $KeyCodes,

        [uint32] $DurationInMilliseconds
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 31
    if ($DurationInMilliseconds -gt 0) {
        Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 33

        $durationArg = " -t $DurationInMilliseconds"
    }

    Invoke-AdbExpression -DeviceId $DeviceId -Command "shell input keycombination$durationArg $($KeyCodes | ForEach-Object { "KEYCODE_$_" })" -Verbose:$VerbosePreference | Out-Null
}
