# https://stackoverflow.com/questions/25864385/changing-android-device-orientation-with-adb
function Get-AdbRotation {

    [CmdletBinding()]
    [OutputType([bool[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [switch] $AsCode
    )

    process {
        $DeviceId `
        | Invoke-AdbExpression -Command "shell settings get system user_rotation" -Verbose:$VerbosePreference `
        | ForEach-Object {
            if ($AsCode) {
                [uint32] $_
            }
            else {
                switch ($_) {
                    '0' { 'Portrait' }
                    '1' { 'Landscape' }
                    '2' { 'ReversePortrait' }
                    '3' { 'ReverseLandscape' }
                }
            }
        }
    }
}
