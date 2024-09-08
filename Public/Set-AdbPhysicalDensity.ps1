function Set-AdbPhysicalDensity {

    [CmdletBinding(DefaultParameterSetName = "Default")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        # Limit to 10,000 to avoid crashing the emulator
        [ValidateRange(72, 10000)]
        [Parameter(Mandatory, ParameterSetName = "Default")]
        [uint32] $Density,

        [Parameter(ParameterSetName = "Reset")]
        [switch] $Reset
    )

    process {
        foreach ($id in $DeviceId) {
            if ($Reset) {
                Invoke-AdbExpression -DeviceId $id -Command "shell wm size reset"
                continue
            }
            Invoke-AdbExpression -DeviceId $id -Command "shell wm size $($Width)x$($Height)"
        }
    }
}
