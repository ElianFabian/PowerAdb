function Get-AdbSystemLocale {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    $apiLevel = Get-AdbApiLevel -DeviceId $DeviceId -Verbose:$false
    if ($apiLevel -ge 24) {
        $systemLocaleList = Get-AdbSetting -DeviceId $DeviceId -Namespace system -Name 'system_locales' -Verbose:$VerbosePreference
        if ($systemLocaleList -like '*null*') {
            Get-AdbProperty -DeviceId $DeviceId -Name 'ro.product.locale' -Verbose:$VerbosePreference
        }
        else {
            $systemLocaleList.Split(',')
        }
    }
    elseif ($apiLevel -ge 23) {
        $systemLocale = Get-AdbProperty -DeviceId $DeviceId -Name 'persist.sys.locale' -Verbose:$VerbosePreference
        if ($systemLocale -cmatch "^[a-z]{2}-[A-Z]{2}$") {
            $systemLocale
        }
        else {
            Get-AdbProperty -DeviceId $DeviceId -Name 'ro.product.locale' -Verbose:$VerbosePreference
        }
    }
    elseif ($apiLevel -ge 16) {
        $systemLanguage = Get-AdbProperty -DeviceId $DeviceId -Name 'persist.sys.language' -Verbose:$VerbosePreference
        if ($systemLanguage) {
            $systemCountry = Get-AdbProperty -DeviceId $DeviceId -Name 'persist.sys.country' -Verbose:$VerbosePreference

            "$systemLanguage-$systemCountry"
        }
        else {
            $defaultSystemLanguage = Get-AdbProperty -DeviceId $DeviceId -Name 'ro.product.locale.language' -Verbose:$VerbosePreference
            $defaultSystemCountry = Get-AdbProperty -DeviceId $DeviceId -Name 'ro.product.locale.region' -Verbose:$VerbosePreference

            "$defaultSystemLanguage-$defaultSystemCountry"
        }
    }
}
