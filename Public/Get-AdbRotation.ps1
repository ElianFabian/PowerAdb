# https://stackoverflow.com/questions/25864385/changing-android-device-orientation-with-adb
function Get-AdbRotation {

    [CmdletBinding()]
    [OutputType([string], [int])]
    param (
        [string] $DeviceId,

        [switch] $AsCode,

        [switch] $Force
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 17

    if ($Force) {
        Disable-AdbAutoRotate -DeviceId $DeviceId
    }
    else {
        if (Test-AdbAutoRotate -DeviceId $DeviceId -Verbose:$false) {
            Write-Warning "Can't set rotation if 'Auto-rotate' is enabled. Use -Force or disable it yourself."
        }
    }

    $result = Get-AdbSetting -DeviceId $DeviceId -Namespace system -Key 'user_rotation' -Verbose:$VerbosePreference

    if ($AsCode) {
        [int] $result
    }
    else {
        switch ($result) {
            '0' { 'Portrait' }
            '1' { 'Landscape' }
            '2' { 'ReversePortrait' }
            '3' { 'ReverseLandscape' }
        }
    }
}
