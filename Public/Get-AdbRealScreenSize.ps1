function Get-AdbRealScreenSize {

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    Get-AdbServiceDump -DeviceId $DeviceId -Name 'display' -Verbose:$VerbosePreference `
    | Select-String -Pattern "mStableDisplaySize=Point\((?<width>\d+), (?<height>\d+)\)" `
    | ForEach-Object { $_.Matches } `
    | Select-Object -First 1 `
    | ForEach-Object {
        $width = [int] $_.Groups["width"].Value
        $height = [int] $_.Groups["height"].Value

        [PSCustomObject]@{
            Width  = [int] $width
            Height = [int] $height
        }
    }
}
