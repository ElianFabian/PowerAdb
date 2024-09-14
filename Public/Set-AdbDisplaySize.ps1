function Set-AdbDisplaySize {

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
            if ($apiLevel -lt 18) {
                Write-Error "Physical density is not supported for device with id '$id' with API level of '$apiLevel'. Only API levels 18 and above are supported."
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
