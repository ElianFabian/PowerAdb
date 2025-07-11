# https://stackoverflow.com/questions/25864385/changing-android-device-orientation-with-adb
function Disable-AdbAutoRotate {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 17

    Set-AdbSetting -SerialNumber $SerialNumber -Namespace system -Name 'accelerometer_rotation' -Value 0 -Verbose:$VerbosePreference
}
