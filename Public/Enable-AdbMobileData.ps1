function Enable-AdbMobileData {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 17

    Set-AdbSetting -SerialNumber $SerialNumber -Namespace global -Name 'mobile_data' -Value '1' -Verbose:$VerbosePreference
}
