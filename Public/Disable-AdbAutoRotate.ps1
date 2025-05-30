# https://stackoverflow.com/questions/25864385/changing-android-device-orientation-with-adb
function Disable-AdbAutoRotate {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 17

    Set-AdbSetting -DeviceId $DeviceId -Namespace system -Name 'accelerometer_rotation' -Value 0 -Verbose:$VerbosePreference
}
