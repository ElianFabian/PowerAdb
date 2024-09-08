function Close-AdbKeyboard {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $DeviceId
    )

    process {
        $DeviceId | Send-AdbKeyEvent -KeyCode ESCAPE
    }
}
