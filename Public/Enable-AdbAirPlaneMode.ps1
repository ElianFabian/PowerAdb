function Enable-AdbAirPlaneMode {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 28) {
                Write-Error "Unsupported API level: '$apiLevel'. Only API levels 28 and above are supported."
                continue
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell cmd connectivity airplane-mode enable" -Verbose:$VerbosePreference
        }
    }
}

# TODO: Check out:
# - https://stackoverflow.com/questions/44135419/airplane-mode-with-out-lose-wifi-and-bluetooth-using-adb
# - https://stackoverflow.com/questions/20130530/use-adb-to-check-if-airplane-mode-is-turned-on
