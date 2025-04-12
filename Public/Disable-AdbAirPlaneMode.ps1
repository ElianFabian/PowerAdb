function Disable-AdbAirPlaneMode {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 28

    Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell cmd connectivity airplane-mode disable' -Verbose:$VerbosePreference
}
