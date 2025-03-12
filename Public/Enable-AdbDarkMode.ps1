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
                Write-ApiLevelError -DeviceId $id -ApiLevelLessThan 29
                continue
            }
            Invoke-AdbExpression -DeviceId $id -Command "shell cmd uimode night yes" -Verbose:$VerbosePreference > $null
        }
    }
}
