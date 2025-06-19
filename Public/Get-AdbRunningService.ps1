function Get-AdbRunningService {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command 'shell dumpsys -l' -Verbose:$VerbosePreference `
    | Select-Object -Skip 1 `
    | Where-Object { $_ } `
    | ForEach-Object { $_.Trim() }
}
