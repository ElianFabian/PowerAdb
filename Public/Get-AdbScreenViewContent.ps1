function Get-AdbScreenViewContent {

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [string] $DeviceId
    )

    $apiLevel = Get-AdbApiLevel -DeviceId $DeviceId -Verbose:$false

    $result = if ($apiLevel -ge 23) {
        Invoke-AdbExpression -DeviceId $DeviceId -Command "exec-out uiautomator dump /dev/tty" -Verbose:$VerbosePreference
    }
    else {
        # Skips warning 'WARNING: linker: libdvm.so has text relocations. This is wasting memory and is a security risk. Please fix.'
        $skip = if ($apiLevel -eq 19) { 1 } else { 0 }
        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell uiautomator dump /dev/tty" -Verbose:$VerbosePreference | Select-Object -Skip $skip | Out-String
    }

    if ('ERROR: could not get idle state.' -eq $result) {
        throw [System.TimeoutException]::new($result)
    }

    if (-not $result) {
        return
    }

    ($result.Trim().GetEnumerator() `
    | Select-Object -Skip "<?xml version='1.0' encoding='UTF-8' standalone='yes' ?>".Length `
    | Select-Object -SkipLast "UI hierchary dumped to: /dev/tty".Length) -join ''
}
