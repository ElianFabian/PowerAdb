# https://stackoverflow.com/questions/25864385/changing-android-device-orientation-with-adb
function Test-AdbAutoRotate {

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    $result = Get-AdbSetting -DeviceId $DeviceId -Namespace system -Key 'accelerometer_rotation' -Verbose:$VerbosePreference
    if ($result) {
        return $result -eq '1'
    }
}
