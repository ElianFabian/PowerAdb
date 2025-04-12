function Open-AdbKeyboard {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId
    )

    Send-AdbKeyEvent -DeviceId $DeviceId -KeyCode BUTTON_START -Verbose:$VerbosePreference
}
