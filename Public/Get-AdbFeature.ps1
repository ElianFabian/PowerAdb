function Get-AdbFeature {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [string] $SerialNumber
    )

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command 'shell pm list features' -Verbose:$VerbosePreference `
    | Select-Object -Skip 1 <# Skips 'reqGlEsVersion=0x30002 #> `
    | ForEach-Object { $_.Replace('feature:', '') }
}
