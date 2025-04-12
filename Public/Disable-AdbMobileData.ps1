function Disable-AdbMobileData {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 17

    Set-AdbSetting -DeviceId $DeviceId -Namespace global -Key 'mobile_data' -Value '0' -Verbose:$VerbosePreference
}
