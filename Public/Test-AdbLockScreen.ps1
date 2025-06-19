function Test-AdbLockScreen {

    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    $topActivity = Get-AdbTopActivity -SerialNumber $SerialNumber -Verbose:$false

    -not $topActivity
}
