function Test-AdbLockScreen {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            # Get-TopActivity returns null if the user is on the lock screen
            $topActivity = Get-AdbTopActivity -DeviceId $id -Verbose:$false

            -not $topActivity
        }
    }
}
