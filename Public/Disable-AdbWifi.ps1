function Disable-AdbWifi {
    
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 30) {
                Write-Error "Enable wifi is not supported for device with id '$id' with API level of '$apiLevel'. Only API levels 30 and above are supported."
                continue
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell cmd -w wifi set-wifi-enabled disabled" -Verbose:$VerbosePreference
        }
    }
}
