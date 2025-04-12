function Enable-AdbLocation {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 17

    $apiLevel = Get-AdbApiLevel -DeviceId $DeviceId -Verbose:$false
    if ($apiLevel -ge 29) {
        Set-AdbSetting -DeviceId $DeviceId -Namespace secure -Key 'location_mode' -Value 3 -Verbose:$VerbosePreference
    }
    elseif ($apiLevel -ge 17) {
        # Set only 'gps' instead of 'gps,network' to avoid showing location consent dialog
        Set-AdbSetting -DeviceId $DeviceId -Namespace secure -Key location_providers_allowed -Value 'gps' -Verbose:$VerbosePreference
    }
}
