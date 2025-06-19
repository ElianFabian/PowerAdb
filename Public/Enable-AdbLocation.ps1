function Enable-AdbLocation {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 17

    $apiLevel = Get-AdbApiLevel -SerialNumber $SerialNumber -Verbose:$false
    if ($apiLevel -ge 29) {
        Set-AdbSetting -SerialNumber $SerialNumber -Namespace secure -Name 'location_mode' -Value 3 -Verbose:$VerbosePreference
    }
    elseif ($apiLevel -ge 17) {
        # Set only 'gps' instead of 'gps,network' to avoid showing location consent dialog
        Set-AdbSetting -SerialNumber $SerialNumber -Namespace secure -Name 'location_providers_allowed' -Value 'gps' -Verbose:$VerbosePreference
    }
}
