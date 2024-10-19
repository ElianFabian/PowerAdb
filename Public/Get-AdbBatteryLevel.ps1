function Get-AdbBatteryLevel {

    [OutputType([int])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys battery" -Verbose:$VerbosePreference `
            | Select-String -Pattern "  level: (\d+)" -AllMatches `
            | ForEach-Object {
                [int] $_.Matches.Groups[1].Value
            }
        }
    }
}
