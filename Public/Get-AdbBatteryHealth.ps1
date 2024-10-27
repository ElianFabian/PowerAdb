function Get-AdbBatteryHealth {

    [OutputType([int[]])]
    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [switch] $AsCode
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys battery" -Verbose:$VerbosePreference `
            | Select-String -Pattern "  health: (\d+)" -AllMatches `
            | ForEach-Object {
                $healthCode = [int] $_.Matches.Groups[1].Value
               
                if ($AsCode) {
                    $healthCode
                }
                else {
                    switch ($healthCode) {
                        1 { "Unknown" }
                        2 { "Good" }
                        3 { "Overheated" }
                        4 { "Dead" }
                        5 { "Overvoltage" }
                        6 { "Failed" }
                        7 { "Cold" }
                        default { "UnknownHealth" }
                    }
                }
            }
        }
    }
}
