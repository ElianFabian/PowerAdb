# https://stackoverflow.com/questions/25864385/changing-android-device-orientation-with-adb
function Enable-AdbAutoRotate {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId `
        | Invoke-AdbExpression -Command "shell settings put system accelerometer_rotation 1" -Verbose:$VerbosePreference
    }
}
