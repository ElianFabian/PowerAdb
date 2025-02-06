function Test-AdbLockScreen {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $topActivity = Get-AdbTopActivity -DeviceId $id -Verbose:$false

            $isLocked = -not $topActivity

            $isLocked
        }
    }
}
