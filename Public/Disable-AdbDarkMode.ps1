function Disable-AdbDarkMode {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId
    )

    # The command exists on API level 29, but at least on emulators it does not allow to set the value
    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 30

    Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell cmd -w uimode night no' -Verbose:$VerbosePreference > $null
}
