function Close-AdbKeyboard {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber
    )

    Send-AdbKeyEvent -SerialNumber $SerialNumber -KeyCode ESCAPE -Verbose:$VerbosePreference
}
