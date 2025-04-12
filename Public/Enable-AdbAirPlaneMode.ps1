function Enable-AdbAirPlaneMode {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 28

    Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell cmd connectivity airplane-mode enable' -Verbose:$VerbosePreference
}

# TODO: Check out:
# - https://stackoverflow.com/questions/44135419/airplane-mode-with-out-lose-wifi-and-bluetooth-using-adb
# - https://stackoverflow.com/questions/20130530/use-adb-to-check-if-airplane-mode-is-turned-on
