function Get-AdbFontScale {

    [OutputType([double])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 17

    $result = Get-AdbSetting -SerialNumber $SerialNumber -Namespace system -Name 'font_scale' -Verbose:$VerbosePreference
    if ($result) {
        return [double] $result
    }
    else {
        # When it's null it means it's the default value, 1
        return 1.0
    }
}
