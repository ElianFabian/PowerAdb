function Get-AdbDiagonalScreenSize {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id
            if ($apiLevel -lt 18) {
                Write-ApiLevelError -DeviceId $id -ApiLevelLessThan 18
                continue
            }

            $realScreenDensity = Get-AdbRealPhysicalDensity -DeviceId $id
            $screenSize = Get-AdbScreenSize -DeviceId $id

            [math]::Sqrt(($screenSize.PhysicalWidth / $realScreenDensity) * ($screenSize.PhysicalWidth / $realScreenDensity) + ($screenSize.PhysicalHeight / $realScreenDensity) * ($screenSize.PhysicalHeight / $realScreenDensity))
        }
    }
}
