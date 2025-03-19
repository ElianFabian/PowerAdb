function Get-AdbTopActivity {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys activity activities" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
            | Select-String -Pattern "(topResumedActivity=.+|mResumedActivity: ActivityRecord){.+ .+ (.+) .+}" -AllMatches `
            | Select-Object -ExpandProperty Matches -First 1 `
            | Select-Object -ExpandProperty Groups -Last 1 `
            | Select-Object -ExpandProperty Value -Last 1 `
            | ForEach-Object {
                $packageName, $activityClassName = $_.Split('/')

                [PSCustomObject]@{
                    DeviceId = $id
                    PackageName = $packageName
                    ActivityClassName = $activityClassName
                }
            }
        }
    }
}
