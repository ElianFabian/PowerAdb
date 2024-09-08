function Set-AdbDisplaySize {

    [CmdletBinding(DefaultParameterSetName = "Default")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory, ParameterSetName = "Default")]
        [uint] $Width,

        [Parameter(Mandatory, ParameterSetName = "Default")]
        [uint] $Height,

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
