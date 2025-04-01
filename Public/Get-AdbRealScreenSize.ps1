function Get-AdbRealScreenSize {

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    foreach ($id in $DeviceId) {
        Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys display" `
        | Select-String -Pattern "mStableDisplaySize=Point\((?<width>\d+), (?<height>\d+)\)" `
        | ForEach-Object { $_.Matches } `
        | Select-Object -First 1 `
        | ForEach-Object {
            $width = [int] $_.Groups["width"].Value
            $height = [int] $_.Groups["height"].Value

            [PSCustomObject]@{
                DeviceId = $id
                Width    = [int] $width
                Height   = [int] $height
            }
        }
    }
}
