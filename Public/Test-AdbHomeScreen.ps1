function Test-AdbHomeScreen {

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 28

    $topActivity = Get-AdbTopActivity -DeviceId $DeviceId -Raw

    $homeLauncherIntent = New-AdbIntent -Action 'android.intent.action.MAIN' -Category 'android.intent.category.HOME'
    $homeLauncherActivity = Resolve-AdbActivity -DeviceId $DeviceId -Intent $homeLauncherIntent -Raw

    return $topActivity -eq $homeLauncherActivity
}
