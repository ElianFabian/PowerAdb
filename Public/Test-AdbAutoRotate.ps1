# https://stackoverflow.com/questions/25864385/changing-android-device-orientation-with-adb
function Test-AdbAutoRotate {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId `
        | Invoke-AdbExpression -Command "shell settings get system accelerometer_rotation" -Verbose:$VerbosePreference `
        | ForEach-Object { if ($_ -eq '1') { $true } else { $false } }
    }
}
