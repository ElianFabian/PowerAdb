function Disable-AdbLocation {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -ge 29) {
                Set-AdbSetting -DeviceId $id -Namespace Secure -Key 'location_mode' -Value 0 -Verbose:$VerbosePreference
            }
            elseif ($apiLevel -ge 17) {
                Set-AdbSetting -DeviceId $id -Namespace Secure -Key location_providers_allowed -Value '-'
            }
            else {
                Write-Error "Unsupported API level: '$apiLevel'. Only API levels 17 and above are supported."
            }
        }
    }
}
