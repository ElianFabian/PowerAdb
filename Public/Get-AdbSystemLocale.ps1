function Get-AdbSystemLocale {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string[]] $DeviceId
    )

    foreach ($id in $DeviceId) {
        $apiLevel = Get-AdbApiLevel -DeviceId $id
        if ($apiLevel -ge 24) {
            $systemLocaleList = Get-AdbSetting -DeviceId $id -Namespace System -key 'system_locales'
            if ($systemLocaleList -like '*null*') {
                Get-AdbProp -DeviceId $id -PropertyName ro.product.locale
                continue
            }

            $systemLocaleList.Split(',')
        }
        else {
            $systemLocale = Get-AdbProp -DeviceId $id -PropertyName persist.sys.locale
            if ($systemLocale -cmatch "^[a-z]{2}-[A-Z]{2}$") {
                $systemLocale
            } else {
                Get-AdbProp -DeviceId $id -PropertyName ro.product.locale
            }
        }
    }
}
