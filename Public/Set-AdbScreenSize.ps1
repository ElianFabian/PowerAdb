function Set-AdbScreenSize {

    [CmdletBinding(
        SupportsShouldProcess,
        DefaultParameterSetName = "Default"
    )]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory, ParameterSetName = "Default")]
        [uint32] $Width,

        [Parameter(Mandatory, ParameterSetName = "Default")]
        [uint32] $Height,

        [Parameter(ParameterSetName = "Reset")]
        [switch] $Reset
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$VerbosePreference
            if ($apiLevel -lt 18) {
                Write-ApiLevelError -DeviceId $id -ApiLevelLessThan 18
                continue
            }

            if ($Reset) {
                Invoke-AdbExpression -DeviceId $id -Command "shell wm size reset" -Verbose:$VerbosePreference
                continue
            }
            Invoke-AdbExpression -DeviceId $id -Command "shell wm size $($Width)x$($Height)" -Verbose:$VerbosePreference
        }
    }
}
