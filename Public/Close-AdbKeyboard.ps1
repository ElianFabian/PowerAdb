function Close-AdbKeyboard {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId | Send-AdbKeyEvent -KeyCode ESCAPE
    }
}
