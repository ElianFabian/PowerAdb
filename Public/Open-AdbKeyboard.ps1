function Open-AdbKeyboard {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber
    )

    Send-AdbKeyEvent -SerialNumber $SerialNumber -KeyCode BUTTON_START -Verbose:$VerbosePreference
}
