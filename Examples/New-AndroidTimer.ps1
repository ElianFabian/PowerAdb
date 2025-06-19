function New-AndroidTimer {

    param (
        [Parameter(Mandatory)]
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [uint32] $Seconds,

        [string] $Message,

        [switch] $SkipUi
    )

    $intent = New-AdbIntent `
        -Action 'android.intent.action.SET_TIMER' `
        -Extras {
        New-AdbBundlePair -Key 'android.intent.extra.alarm.LENGTH' -Int $Seconds
        if ($Message) {
            New-AdbBundlePair -Key 'android.intent.extra.alarm.MESSAGE' -String $Message
        }
        New-AdbBundlePair -Key 'android.intent.extra.alarm.SKIP_UI' -Boolean $SkipUi
    }

    Start-AdbActivity -SerialNumber $SerialNumber -Intent $intent
}
