function Test-AdbAutoRotate {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId
        | Invoke-AdbExpression -Command "shell settings get system accelerometer_rotation"
        | ForEach-Object { if ($_ -eq '1') { $true } else { $false } }
    }
}
