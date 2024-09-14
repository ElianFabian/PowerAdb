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
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 18) {
                Write-Error "Physical density is not supported for device with id '$id' with API level of '$apiLevel'. Only API levels 18 and above are supported."
                continue
            }
            if ($Reset) {
                Invoke-AdbExpression -DeviceId $id -Command "shell wm density reset"
                continue
            }
            Invoke-AdbExpression -DeviceId $id -Command "shell wm density $Density"
        }
    }
}
