function Get-AdbBatteryStatus {

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
            | Select-String -Pattern "  status: (\d+)" -AllMatches `
            | ForEach-Object {
                $statusCode = [int] $_.Matches.Groups[1].Value
               
                if ($AsCode) {
                    $statusCode
                }
                else {
                    switch ($statusCode) {
                        1 { "Unknown" }
                        2 { "Charging" }
                        3 { "Discharging" }
                        4 { "NotCharging" }
                        5 { "Full" }
                        default { "UnknownStatus" }
                    }
                }
            }
        }
    }
}
