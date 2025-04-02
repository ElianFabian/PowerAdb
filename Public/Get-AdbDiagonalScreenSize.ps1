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
            $screenSize = Get-AdbRealScreenSize -DeviceId $id

            [math]::Sqrt(($screenSize.Width / $realScreenDensity) * ($screenSize.Width / $realScreenDensity) + ($screenSize.Height / $realScreenDensity) * ($screenSize.Height / $realScreenDensity))
        }
    }
}
