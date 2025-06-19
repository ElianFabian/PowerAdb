function Get-AdbDiagonalScreenSize {

    [OutputType([double])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 18

    $realScreenDensity = Get-AdbRealDensity -SerialNumber $SerialNumber
    $screenSize = Get-AdbRealScreenSize -SerialNumber $SerialNumber

    $widthInInch = $screenSize.Width / $realScreenDensity
    $heightInInch = $screenSize.Height / $realScreenDensity

    return [math]::Sqrt($widthInInch * $widthInInch + $heightInInch * $heightInInch)
}
