function Set-AdbScreenSize {

    [CmdletBinding(
        SupportsShouldProcess,
        DefaultParameterSetName = "Default"
    )]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory, ParameterSetName = "Default")]
        [uint32] $Width,

        [Parameter(Mandatory, ParameterSetName = "Default")]
        [uint32] $Height,

        [Parameter(ParameterSetName = "Reset")]
        [switch] $Reset
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 18

    if ($Reset) {
        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell wm size reset" -Verbose:$VerbosePreference
        return
    }
    Invoke-AdbExpression -DeviceId $DeviceId -Command "shell wm size $($Width)x$($Height)" -Verbose:$VerbosePreference
}
