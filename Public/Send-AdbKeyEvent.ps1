function Send-AdbKeyEvent {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [ValidateCount(1, [int]::MaxValue)]
        [Parameter(Mandatory)]
        [string[]] $KeyCode
    )

    foreach ($code in $KeyCode) {
        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell input keyevent KEYCODE_$code" -Verbose:$VerbosePreference | Out-Null
    }
}
