function Disable-AdbMobileData {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 17) {
                Write-ApiLevelError -DeviceId $id -ApiLevelLessThan 17
                continue
            }

            Set-AdbSetting -DeviceId $id -Namespace Global -Key "mobile_data" -Value "0" -Verbose:$VerbosePreference
        }
    }
}
