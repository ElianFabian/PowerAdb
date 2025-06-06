function Test-AdbScreenLocked {

    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 23

    # https://android.stackexchange.com/a/245699
    $rawData = Get-AdbServiceDump -DeviceId $DeviceId -Name 'deviceidle' -Verbose:$VerbosePreference

    $rawData `
    | Where-Object { $_.Contains('mScreenLocked=') } `
    | Select-Object -First 1 `
    | Select-String -Pattern 'mScreenLocked=(true|false)' `
    | ForEach-Object {
        $_.Matches.Groups[1].Value -eq 'true'
    }
}
