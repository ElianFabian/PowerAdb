function Test-AdbKeyboardOpen {

    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [string] $DeviceId
    )

    Get-AdbServiceDump -DeviceId $DeviceId -Name 'input_method' -Verbose:$VerbosePreference `
    | Select-String -Pattern "mInputShown=(true|false)" `
    | Select-Object -ExpandProperty Matches -First 1 `
    | Select-Object -ExpandProperty Groups -First 2 `
    | Select-Object -ExpandProperty Value -Last 1 `
    | ForEach-Object { [bool]::Parse($_) }
}
