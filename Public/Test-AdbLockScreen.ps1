function Test-AdbLockScreen {

    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    $topActivity = Get-AdbTopActivity -DeviceId $DeviceId -Verbose:$false

    -not $topActivity
}
