function Disable-AdbMobileData {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 17

    Set-AdbSetting -DeviceId $DeviceId -Namespace global -Name 'mobile_data' -Value '0' -Verbose:$VerbosePreference
}
