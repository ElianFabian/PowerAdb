function Test-AdbDeviceLocked {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            # Source: https://stackoverflow.com/a/60037241/18418162
            Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys window" -Verbose:$VerbosePreference `
            | Select-String -Pattern "mDreamingLockscreen=(true|false)" `
            | ForEach-Object {
                [bool]::Parse($_.Matches.Groups[1].Value)
            }
        }
    }
}
