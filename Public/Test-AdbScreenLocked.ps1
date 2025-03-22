function Test-AdbScreenLocked {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    foreach ($id in $DeviceId) {
        $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
        if ($apiLevel -lt 23) {
            Write-ApiLevelError -DeviceId $id -ApiLevelLessThan 23
            continue
        }

        # https://android.stackexchange.com/a/245699
        $rawData = Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys deviceidle" -Verbose:$VerbosePreference

        $rawData | Select-String -Pattern 'mScreenLocked=(true|false)' | ForEach-Object {
            $_.Matches.Groups[1].Value -eq 'true'
        }
    }
}
