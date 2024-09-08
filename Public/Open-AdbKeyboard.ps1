function Open-AdbKeyboard {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $id | Send-AdbKeyEvent -KeyCode BUTTON_START
        }
    }
}
