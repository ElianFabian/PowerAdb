function Get-AdbFontScale {

    [OutputType([double])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 17

    $result = Get-AdbSetting -DeviceId $DeviceId -Namespace system -Name 'font_scale' -Verbose:$VerbosePreference
    if ($result) {
        return [double] $result
    }
    else {
        # When it's null it means it's the default value, 1
        return 1.0
    }
}
