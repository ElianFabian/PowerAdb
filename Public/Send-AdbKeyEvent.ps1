function Send-AdbKeyEvent {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [ValidateCount(1, [int]::MaxValue)]
        [Parameter(Mandatory)]
        [string[]] $KeyCode
    )

    process {
        foreach ($id in $DeviceId) {
            foreach ($code in $KeyCode) {
                Invoke-AdbExpression -DeviceId $id -Command "shell input keyevent KEYCODE_$code" -Verbose:$VerbosePreference | Out-Null
            }
        }
    }
}
