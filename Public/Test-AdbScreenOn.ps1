# https://stackoverflow.com/questions/21409044/how-to-tell-if-screen-is-on-with-adb

function Test-AdbScreenOn {

    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [string] $DeviceId
    )

    Get-AdbServiceDump -DeviceId $DeviceId -Name 'input_method' -Verbose:$VerbosePreference `
    | Out-String | Select-String -Pattern "(mScreenOn|screenOn = |mInteractive=)(true|false)" -AllMatches `
    | Select-Object -ExpandProperty Matches `
    | Select-Object -ExpandProperty Groups `
    | Select-Object -ExpandProperty Value -Last 1 `
    | ForEach-Object { [bool]::Parse($_) }
}
