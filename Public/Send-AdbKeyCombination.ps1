function Send-AdbKeyCombination {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [ValidateCount(2, [int]::MaxValue)]
        [Parameter(Mandatory)]
        [string[]] $KeyCodes,

        [uint32] $DurationInMilliseconds
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 31
    if ($DurationInMilliseconds -gt 0) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 33

        $durationArg = " -t $DurationInMilliseconds"
    }

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell input keycombination$durationArg $($KeyCodes | ForEach-Object { "KEYCODE_$_" })" -Verbose:$VerbosePreference | Out-Null
}
