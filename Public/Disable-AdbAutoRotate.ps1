# https://stackoverflow.com/questions/25864385/changing-android-device-orientation-with-adb
function Disable-AdbAutoRotate {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId | Set-AdbSetting -Namespace System -Key 'accelerometer_rotation' -Value 0 -Verbose:$VerbosePreference
    }
}
