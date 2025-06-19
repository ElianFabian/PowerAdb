function Test-AdbScreenLocked {

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 24

    # https://android.stackexchange.com/a/245699
    $rawData = Get-AdbServiceDump -SerialNumber $SerialNumber -Name 'deviceidle' -Verbose:$VerbosePreference

    $rawData `
    | Where-Object { $_.Contains('mScreenLocked=') } `
    | Select-Object -First 1 `
    | Select-String -Pattern 'mScreenLocked=(true|false)' `
    | ForEach-Object {
        $_.Matches.Groups[1].Value -eq 'true'
    }
}
