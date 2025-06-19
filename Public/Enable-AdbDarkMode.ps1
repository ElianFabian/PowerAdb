function Enable-AdbDarkMode {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber
    )

    # The command exists on API level 29, but at least on emulators it does not allow to set the value
    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 30

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command 'shell cmd -w uimode night yes' -Verbose:$VerbosePreference > $null
}
