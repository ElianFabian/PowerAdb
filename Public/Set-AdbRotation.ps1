# https://stackoverflow.com/questions/25864385/changing-android-device-orientation-with-adb
function Set-AdbRotation {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [ValidateSet(
            'Portrait',
            'Landscape',
            'ReversePortrait',
            'ReverseLandscape',
            '0', '1', '2', '3'
        )]
        [Parameter(Mandatory)]
        [string] $Rotation,

        [switch] $Force
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 17

    if ($Force) {
        Disable-AdbAutoRotate -SerialNumber $SerialNumber
    }
    else {
        if (Test-AdbAutoRotate -SerialNumber $SerialNumber -Verbose:$false) {
            Write-Warning "Can't set rotation if 'Auto-rotate' is enabled. Use -Force or disable it yourself."
        }
    }

    $rotationCode = switch ($Rotation) {
        'Portrait' { 0 }
        'Landscape' { 1 }
        'ReversePortrait' { 2 }
        'ReverseLandscape' { 3 }
        default { $Rotation }
    }

    Set-AdbSetting -SerialNumber $SerialNumber -Namespace system -Name 'user_rotation' -Value $rotationCode -Verbose:$VerbosePreference
}
