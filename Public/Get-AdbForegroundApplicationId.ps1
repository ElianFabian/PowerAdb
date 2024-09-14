function Get-AdbForegroundApplicationId {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId | Invoke-AdbExpression -Command "shell dumpsys window windows" -Verbose:$VerbosePreference `
        | Out-String `
        | Select-String -Pattern ".+mSurface=Surface\(name=(.+)/.+\).+" -AllMatches `
        | Select-Object -ExpandProperty Matches `
        | Select-Object -ExpandProperty Groups -First 1 `
        | Select-Object -ExpandProperty Value -Last 1
    }
}
