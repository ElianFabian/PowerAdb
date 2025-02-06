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
                Write-ApiLevelError -DeviceId $id -ApiLevelLessThan 30
                continue
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell cmd -w wifi set-wifi-enabled disabled" -Verbose:$VerbosePreference
        }
    }
}
