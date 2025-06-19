function Set-AdbScreenSize {

    [CmdletBinding(
        SupportsShouldProcess,
        DefaultParameterSetName = "Default"
    )]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory, ParameterSetName = "Default")]
        [uint32] $Width,

        [Parameter(Mandatory, ParameterSetName = "Default")]
        [uint32] $Height,

        [Parameter(ParameterSetName = "Reset")]
        [switch] $Reset
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 18

    if ($Reset) {
        Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell wm size reset" -Verbose:$VerbosePreference
        return
    }
    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell wm size $($Width)x$($Height)" -Verbose:$VerbosePreference
}
