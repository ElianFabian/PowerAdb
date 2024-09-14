# https://stackoverflow.com/questions/25864385/changing-android-device-orientation-with-adb
function Set-AdbRotation {

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [ValidateSet('Portrait', 'Landscape', 'ReversePortrait', 'ReverseLandscape')]
        [Parameter(Mandatory)]
        [string] $Rotation
    )

    begin {
        $rotationCode = switch ($Rotation) {
            Portrait { 0 }
            Landscape { 1 }
            ReversePortrait { 2 }
            ReverseLandscape { 3 }
        }
    }

    process {
        $DeviceId | Invoke-AdbExpression -Command "shell settings put system user_rotation $rotationCode" -Verbose:$VerbosePreference
    }
}
