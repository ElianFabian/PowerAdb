function Get-AdbSystemLocale {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string[]] $DeviceId
    )

    foreach ($id in $DeviceId) {
        $localeList = Invoke-AdbExpression -DeviceId $id -Command "shell settings get system system_locales"
        $localeList.Split(',')
    }
}
