function Test-AdbBatteryAcPowered {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys battery" -Verbose:$VerbosePreference `
            | Select-String -Pattern "  AC powered: (\w+)" -AllMatches `
            | ForEach-Object {
                $acPowered = $_.Matches.Groups[1].Value -eq "true"
                $acPowered
            }
        }
    }
}
