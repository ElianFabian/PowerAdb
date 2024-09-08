using module "../Class/KeyCode.psm1"

function Send-AdbKeyEvent {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [ValidateCount(1, [int]::MaxValue)]
        [ValidateSet([KeyCode])]
        [Parameter(Mandatory)]
        [string[]] $KeyCode
    )

    process {
        foreach ($id in $DeviceId) {
            foreach ($code in $KeyCode) {
                Invoke-AdbExpression -DeviceId $id -Command "shell input keyevent KEYCODE_$code" | Out-Null
            }
        }
    }
}
