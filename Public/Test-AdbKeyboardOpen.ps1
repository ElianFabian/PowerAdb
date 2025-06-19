function Test-AdbKeyboardOpen {

    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [string] $SerialNumber
    )

    if (Test-AdbScreenLocked -SerialNumber $SerialNumber) {
        return $false
    }

    Get-AdbServiceDump -SerialNumber $SerialNumber -Name 'input_method' -Verbose:$VerbosePreference `
    | Where-Object { $_.Contains('mInputShown=') } `
    | Select-Object -First 1 `
    | Select-String -Pattern "mInputShown=(true|false)" `
    | Select-Object -ExpandProperty Matches -First 1 `
    | Select-Object -ExpandProperty Groups -First 2 `
    | Select-Object -ExpandProperty Value -Last 1 `
    | ForEach-Object { [bool]::Parse($_) }
}
