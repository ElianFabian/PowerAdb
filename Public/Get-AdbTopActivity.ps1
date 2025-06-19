function Get-AdbTopActivity {

    [CmdletBinding()]
    [OutputType([string], [PSCustomObject])]
    param (
        [string] $SerialNumber,

        [switch] $Raw
    )

    # Returns null if the user is on the lock screen
    Get-AdbServiceDump -SerialNumber $SerialNumber -Name 'activity' -ArgumentList 'activities' -Verbose:$VerbosePreference `
    | Select-String -Pattern '(topResumedActivity=.+|mResumedActivity: ActivityRecord){.+ .+ (.+) .+}' -AllMatches `
    | Select-Object -ExpandProperty Matches -First 1 `
    | Select-Object -ExpandProperty Groups -Last 1 `
    | Select-Object -ExpandProperty Value -Last 1 `
    | ForEach-Object {
        if ($Raw) {
            $_
        }
        else {
            $packageName, $activityClassName = $_.Split('/')

            [PSCustomObject]@{
                PackageName       = $packageName
                ActivityClassName = $activityClassName
            }
        }
    }
}
