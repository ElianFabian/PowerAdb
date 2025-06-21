function Get-AdbVibratorId {

    [OutputType([int[]])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 31

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell cmd vibrator_manager list" -Verbose:$VerbosePreference `
    | Where-Object { $_ } `
    | ForEach-Object { [int] $_ }
}
