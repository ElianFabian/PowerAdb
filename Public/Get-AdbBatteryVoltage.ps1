function Get-AdbBatteryVoltage {
    
    [OutputType([float])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )
    
    process {
        foreach ($id in $DeviceId) {
            $result = Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys battery" -Verbose:$VerbosePreference `
            | Select-String -Pattern "  voltage:\s?(\d+)" -AllMatches

            if ($result.Matches.Count -eq 0) {
                [float]::NaN
            }
            else {
                $result | ForEach-Object {
                    $voltageInMillivolts = [int] $_.Matches.Groups[1].Value
                    [float] ($voltageInMillivolts / 1000.0)
                }
            }
        }
    }
}
