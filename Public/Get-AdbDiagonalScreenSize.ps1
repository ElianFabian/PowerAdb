function Get-AdbDiagonalScreenSize {

    [OutputType([double])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 18

    $realScreenDensity = Get-AdbRealDensity -DeviceId $DeviceId
    $screenSize = Get-AdbRealScreenSize -DeviceId $DeviceId

    $widthInInch = $screenSize.Width / $realScreenDensity
    $heightInInch = $screenSize.Height / $realScreenDensity

    return [math]::Sqrt($widthInInch * $widthInInch + $heightInInch * $heightInInch)
}
