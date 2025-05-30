function Disable-AdbWifi {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 30

    Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell cmd -w wifi set-wifi-enabled disabled' -Verbose:$VerbosePreference
}
