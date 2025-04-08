function Get-AdbScreenViewContent {

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = [uint32] (Get-AdbProperty -DeviceId $id -Name 'ro.build.version.sdk' -Verbose:$false)
            if ($apiLevel -le 23) {
                Write-ApiLevelError -DeviceId $id -ApiLevelLessThan 23
                continue
            }

            $ouput = Invoke-AdbExpression -DeviceId $id -Command "exec-out uiautomator dump /dev/tty" -Verbose:$VerbosePreference

            if (-not $ouput) {
                continue
            }

            ($ouput.GetEnumerator() `
            | Select-Object -Skip "<?xml version='1.0' encoding='UTF-8' standalone='yes' ?>".Length `
            | Select-Object -SkipLast "UI hierchary dumped to: /dev/tty".Length) -join ''
        }
    }
}
