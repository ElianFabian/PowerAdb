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
                Write-Error "'adb exec-out uiautomator dump' is not available for api levels lower or equal to 23. Device id: '$id', api level: '$apiLevel'"
                continue
            }
        }
        $DeviceId | Invoke-AdbExpression -Command "exec-out uiautomator dump /dev/tty" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
        | Out-String `
        | ForEach-Object { $_.Replace("UI hierchary dumped to: /dev/tty", "") } `
        | ForEach-Object {
            # Suppress any possible exception stacktrance like "java.io.FileNotFoundException [...]
            # Caused by: android.system.ErrnoException: open failed: ENOENT (No such file or directory) [...]"
            $xmlHeaderIndex = $_.IndexOf("<?xml version='1.0' encoding='UTF-8' standalone='yes' ?>")
            $_.Substring($xmlHeaderIndex)
        }
    }
}
