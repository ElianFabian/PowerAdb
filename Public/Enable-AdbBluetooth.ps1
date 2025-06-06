function Enable-AdbBluetooth {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 33

    Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell cmd bluetooth_manager enable' -Verbose:$VerbosePreference
}
