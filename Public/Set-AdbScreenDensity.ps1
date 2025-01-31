function Set-AdbScreenDensity {

    [CmdletBinding(
        SupportsShouldProcess,
        DefaultParameterSetName = "Default"
    )]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory, ParameterSetName = "Default")]
        [uint32] $Density,

        # This is the value that appears in developer settings.
        # Using this parameter makes the function call slower.
        [Parameter(Mandatory, ParameterSetName = "WithInDp")]
        [uint32] $WithInDp,

        [Parameter(ParameterSetName = "Reset")]
        [switch] $Reset
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 18) {
                Write-Error "Screen density is not supported for device with id '$id' with API level of '$apiLevel'. Only API levels 18 and above are supported."
                continue
            }
            if ($Reset) {
                Invoke-AdbExpression -DeviceId $id -Command "shell wm density reset" -Verbose:$VerbosePreference
                continue
            }

            $densityToSet = if ($PSCmdlet.ParameterSetName -eq "WithInDp") {
                $screenSize = Get-AdbScreenSize -DeviceId $id
                [uint32] ($screenSize.Width / ($WithInDp / 160))
            }
            else {
                $Density
            }

            if ($densityToSet -lt 72) {
                if ($PSCmdlet.ParameterSetName -eq "WithInDp") {
                    $withInDpMessage = " (width in dp: $WithInDp)"
                }
                Write-Error "Density cannot be less than 72 for device with id $id. The value provided was '$densityToSet'$withInDpMessage."
                continue
            }

            # Limit to 10,000 to avoid crashing the emulator
            if ($densityToSet -gt 10000) {
                if ($PSCmdlet.ParameterSetName -eq "WithInDp") {
                    $withInDpMessage = " (width in dp: $WithInDp)"
                }
                Write-Error "Density cannot be greater than 10,000 for device with id $id. The value provided was '$densityToSet'$withInDpMessage."
                continue
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell wm density $densityToSet" -Verbose:$VerbosePreference
        }
    }
}
