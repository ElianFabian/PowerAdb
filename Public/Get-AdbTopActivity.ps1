function Get-AdbTopActivity {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId | Invoke-AdbExpression -Command "shell dumpsys activity activities" -Verbose:$VerbosePreference `
        | Select-String -Pattern "(topResumedActivity=.+|mResumedActivity: ActivityRecord){.+ .+ (.+) .+}" -AllMatches `
        | Select-Object -ExpandProperty Matches -First 1 `
        | Select-Object -ExpandProperty Groups -Last 1 `
        | Select-Object -ExpandProperty Value -Last 1 `
        | ForEach-Object {
            $_.Replace('/', '').Trim("}")
        }
    }
}
