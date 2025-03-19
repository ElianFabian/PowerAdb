function Get-AdbSystemLocale {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if (-not $apiLevel) {
                Write-Error "Failed to retrieve the API level for device with id '$id'."
                continue
            }

            if ($apiLevel -ge 24) {
                $systemLocaleList = Get-AdbSetting -DeviceId $id -Namespace System -Key 'system_locales' -Verbose:$VerbosePreference
                if ($systemLocaleList -like '*null*') {
                    Get-AdbProperty -DeviceId $id -Name 'ro.product.locale' -Verbose:$VerbosePreference
                }
                else {
                    $systemLocaleList.Split(',')
                }
            }
            elseif ($apiLevel -ge 23) {
                $systemLocale = Get-AdbProperty -DeviceId $id -Name 'persist.sys.locale' -Verbose:$VerbosePreference
                if ($systemLocale -cmatch "^[a-z]{2}-[A-Z]{2}$") {
                    $systemLocale
                }
                else {
                    Get-AdbProperty -DeviceId $id -Name 'ro.product.locale' -Verbose:$VerbosePreference
                }
            }
            elseif ($apiLevel -ge 16) {
                $systemLanguage = Get-AdbProperty -DeviceId $id -Name 'persist.sys.language' -Verbose:$VerbosePreference
                if ($systemLanguage) {
                    $systemCountry = Get-AdbProperty -DeviceId $id -Name 'persist.sys.country' -Verbose:$VerbosePreference

                    "$systemLanguage-$systemCountry"
                }
                else {
                    $defaultSystemLanguage = Get-AdbProperty -DeviceId $id -Name 'ro.product.locale.language' -Verbose:$VerbosePreference
                    $defaultSystemCountry = Get-AdbProperty -DeviceId $id -Name 'ro.product.locale.region' -Verbose:$VerbosePreference

                    "$defaultSystemLanguage-$defaultSystemCountry"
                }
            }
            else {
                Write-ApiLevelError -DeviceId $id -ApiLevelLessThan 16
            }
        }
    }
}
