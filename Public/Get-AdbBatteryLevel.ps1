function Get-AdbBatteryLevel {

    [OutputType([uint32[]])]
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
                [uint32] $_.Matches.Groups[1].Value
            }
        }
    }
}
