function New-AndroidAlarm {

    param (
        [Parameter(Mandatory)]
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [uint32] $Hour,

        [Parameter(Mandatory)]
        [uint32] $Minute,

        [Parameter(Mandatory)]
        [string] $Message,

        [switch] $SkipUi
    )

    $intent = New-AdbIntent `
        -Action 'android.intent.action.SET_ALARM' `
        -Extras {
        New-AdbBundlePair -Key 'android.intent.extra.alarm.HOUR' -Int $Hour
        New-AdbBundlePair -Key 'android.intent.extra.alarm.MINUTES' -Int $Minute
        New-AdbBundlePair -Key 'android.intent.extra.alarm.MESSAGE' -String $Message
        New-AdbBundlePair -Key 'android.intent.extra.alarm.SKIP_UI' -Boolean $SkipUi
    }

    Start-AdbActivity -DeviceId $DeviceId -Intent $intent
}
