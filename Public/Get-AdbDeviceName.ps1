function Get-AdbDeviceName {

    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            if ((Test-AdbEmulator -DeviceId $id)) {
                [string] (Invoke-AdbExpression -DeviceId $id -Command "emu avd name" | Select-Object -First 1)
                continue
            }
            Get-AdbProp -DeviceId $id -PropertyName "ro.product.model"
        }
    }
}
