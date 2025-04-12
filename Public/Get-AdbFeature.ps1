function Get-AdbFeature {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [string] $DeviceId
    )

    Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell pm list features' -Verbose:$VerbosePreference `
    | Select-Object -Skip 1 <# Skips 'reqGlEsVersion=0x30002 #> `
    | ForEach-Object { $_.Replace('feature:', '') }
}
