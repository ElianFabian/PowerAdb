function Get-AdbSystemLocale {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id
            if (-not $apiLevel) {
                Write-Error "Failed to retrieve the API level for device with id '$id'."
                continue
            }

            if ($apiLevel -ge 24) {
                $systemLocaleList = Get-AdbSetting -DeviceId $id -Namespace System -Key 'system_locales'
                if ($systemLocaleList -like '*null*') {
                    Get-AdbProperty -DeviceId $id -Name 'ro.product.locale'
                }
                else {
                    $systemLocaleList.Split(',')
                }
            }
            elseif ($apiLevel -ge 23) {
                $systemLocale = Get-AdbProperty -DeviceId $id -Name 'persist.sys.locale'
                if ($systemLocale -cmatch "^[a-z]{2}-[A-Z]{2}$") {
                    $systemLocale
                }
                else {
                    Get-AdbProperty -DeviceId $id -Name 'ro.product.locale'
                }
            }
            elseif ($apiLevel -ge 16) {
                $systemLanguage = Get-AdbProperty -DeviceId $id -Name 'persist.sys.language'
                if ($systemLanguage) {
                    $systemCountry = Get-AdbProperty -DeviceId $id -Name 'persist.sys.country'

                    "$systemLanguage-$systemCountry"
                }
                else {
                    $defaultSystemLanguage = Get-AdbProperty -DeviceId $id -Name 'ro.product.locale.language'
                    $defaultSystemCountry = Get-AdbProperty -DeviceId $id -Name 'ro.product.locale.country'

                    "$defaultSystemLanguage-$defaultSystemCountry"
                }
            }
            else {
                Write-Error "Unsupported API level: '$apiLevel'. Only API levels 16 and above are supported."
            }
        }
    }
}
