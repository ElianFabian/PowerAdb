function Close-AdbKeyboard {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId
    )

    Send-AdbKeyEvent -DeviceId DeviceId -KeyCode ESCAPE -Verbose:$VerbosePreference
}
