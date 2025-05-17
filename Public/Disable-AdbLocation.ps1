function Disable-AdbLocation {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 17

    $apiLevel = Get-AdbApiLevel -DeviceId $DeviceId -Verbose:$false
    if ($apiLevel -ge 29) {
        Set-AdbSetting -DeviceId $DeviceId -Namespace secure -Name 'location_mode' -Value 0 -Verbose:$VerbosePreference
    }
    elseif ($apiLevel -ge 17) {
        Set-AdbSetting -DeviceId $DeviceId -Namespace secure -Name 'location_providers_allowed' -Value '-' -Verbose:$VerbosePreference
    }
}
