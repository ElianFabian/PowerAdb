function Test-AdbHomeScreen {

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 28

    $topActivity = Get-AdbTopActivity -SerialNumber $SerialNumber -Raw

    $homeLauncherIntent = New-AdbIntent -Action 'android.intent.action.MAIN' -Category 'android.intent.category.HOME'
    $homeLauncherActivity = Resolve-AdbActivity -SerialNumber $SerialNumber -Intent $homeLauncherIntent -Raw

    return $topActivity -eq $homeLauncherActivity
}
