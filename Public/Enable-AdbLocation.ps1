function Enable-AdbLocation {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -ge 29) {
                Set-AdbSetting -DeviceId $id -Namespace Secure -Key 'location_mode' -Value 3 -Verbose:$VerbosePreference
            }
            elseif ($apiLevel -ge 17) {
                # Set only 'gps' instead of 'gps,network' to avoid showing location consent dialog
                Set-AdbSetting -DeviceId $id -Namespace Secure -Key location_providers_allowed -Value 'gps' -Verbose:$VerbosePreference
            }
            else {
                Write-ApiLevelError -DeviceId $id -ApiLevelLessThan 17
            }
        }
    }
}
