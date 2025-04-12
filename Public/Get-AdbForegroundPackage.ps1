function Get-AdbForegroundPackage {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    # Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell dumpsys window windows' -Verbose:$VerbosePreference `
    Get-AdbServiceDump -DeviceId $DeviceId -Name 'window' -ArgumentList 'windows' -Verbose:$VerbosePreference `
    | Out-String `
    | Select-String -Pattern ".+mSurface=Surface\(name=(.+)/.+\).+" -AllMatches `
    | Select-Object -ExpandProperty Matches `
    | Select-Object -ExpandProperty Groups -First 1 `
    | Select-Object -ExpandProperty Value -Last 1
}
