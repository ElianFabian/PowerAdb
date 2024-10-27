function Enable-AdbMobileData {
    
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 17) {
                Write-Error "Enable mobile data is not supported for device with id '$id' with API level of '$apiLevel'. Only API levels 17 and above are supported."
                continue
            }

            Set-AdbSetting -DeviceId $id -Namespace Global -Key "mobile_data" -Value "1" -Verbose:$VerbosePreference
        }
    }
}
