# https://stackoverflow.com/questions/25864385/changing-android-device-orientation-with-adb
function Test-AdbAutoRotate {

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 17

    $result = Get-AdbSetting -SerialNumber $SerialNumber -Namespace system -Name 'accelerometer_rotation' -Verbose:$VerbosePreference
    if ($result) {
        return $result -eq '1'
    }
}
