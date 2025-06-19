function Send-AdbKeyEvent {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [ValidateCount(1, [int]::MaxValue)]
        [Parameter(Mandatory)]
        [string[]] $KeyCode
    )

    foreach ($code in $KeyCode) {
        Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell input keyevent KEYCODE_$code" -Verbose:$VerbosePreference | Out-Null
    }
}
