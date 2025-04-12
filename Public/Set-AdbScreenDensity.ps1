function Set-AdbScreenDensity {

    [CmdletBinding(
        SupportsShouldProcess,
        DefaultParameterSetName = "Default"
    )]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory, ParameterSetName = "Default")]
        [uint32] $Density,

        # This is the value that appears in developer settings.
        # Using this parameter makes the function call slower.
        [Parameter(Mandatory, ParameterSetName = "WidthInDp")]
        [uint32] $WidthInDp,

        [Parameter(ParameterSetName = "Reset")]
        [switch] $Reset
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 18

    if ($Reset) {
        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell wm density reset" -Verbose:$VerbosePreference
        continue
    }

    $densityToSet = if ($PSCmdlet.ParameterSetName -eq "WidthInDp") {
        $screenSize = Get-AdbScreenSize -DeviceId $DeviceId
        [uint32] ($screenSize.Width / ($WidthInDp / 160))
    }
    else {
        $Density
    }

    if ($densityToSet -lt 72) {
        if ($PSCmdlet.ParameterSetName -eq "WidthInDp") {
            $widthInDpMessage = " (width in dp: $WidthInDp)"
        }
        Write-Error "Density cannot be less than 72 for device with id '$DeviceId'. The value provided was '$densityToSet'$widthInDpMessage." -ErrorAction Stop
    }

    # Limit to 10,000 to avoid crashing the emulator
    if ($densityToSet -gt 10000) {
        if ($PSCmdlet.ParameterSetName -eq "WidthInDp") {
            $widthInDpMessage = " (width in dp: $WidthInDp)"
        }
        Write-Error "Density cannot be greater than 10,000 for device with id '$DeviceId'. The value provided was '$densityToSet'$widthInDpMessage." -ErrorAction Stop
    }

    Invoke-AdbExpression -DeviceId $DeviceId -Command "shell wm density $densityToSet" -Verbose:$VerbosePreference
}
