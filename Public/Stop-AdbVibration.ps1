function Stop-AdbVibration {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 29

    $apiLevel = Get-AdbApiLevel -SerialNumber $SerialNumber -Verbose:$false
    if ($apiLevel -ge 31) {
        Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell cmd vibrator_manager cancel" -Verbose:$VerbosePreference
    }
    else {
        Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell cmd vibrator cancel" -Verbose:$VerbosePreference
    }
}
