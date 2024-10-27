function Get-AdbBatteryTechnology {
    
    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )
    
    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys battery" -Verbose:$VerbosePreference `
            | Select-String -Pattern "  technology: (.+)" -AllMatches `
            | ForEach-Object {
                $_.Matches.Groups[1].Value
            }
        }
    }
}
