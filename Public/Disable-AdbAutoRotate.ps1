function Disable-AdbAutoRotate {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId
        | Invoke-AdbExpression -Command "shell settings put system accelerometer_rotation 0"
    }
}
