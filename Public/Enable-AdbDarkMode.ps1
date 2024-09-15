function Enable-AdbDarkMode {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id
            if ($apiLevel -lt 29) {
                Write-Error "Dark mode not supported for device with id: '$id' and API level '$apiLevel'. Only API levels 29 and above are supported."
                continue
            }
            Invoke-AdbExpression -DeviceId $id -Command "shell cmd uimode night yes" -Verbose:$VerbosePreference > $null
        }
    }
}
