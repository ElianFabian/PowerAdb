# https://stackoverflow.com/questions/25864385/changing-android-device-orientation-with-adb
function Enable-AdbAutoRotate {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId | Set-AdbSetting -Namespace System -Key 'accelerometer_rotation' -Value 1 -Verbose:$VerbosePreference
    }
}
