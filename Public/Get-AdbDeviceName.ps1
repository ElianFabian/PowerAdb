function Get-AdbDeviceName {

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string] $SerialNumber
    )

    $serial = $SerialNumber
    $availableDevices = Get-AdbDevice
    if ($availableDevices.Count -eq 1 -and -not $serial) {
        $serial = $availableDevices
    }

    $deviceName = if ((Test-AdbEmulator -SerialNumber $serial)) {
        [string] (Invoke-AdbExpression -SerialNumber $serial -Command 'emu avd name' -Verbose:$VerbosePreference | Select-Object -First 1)
    }
    else {
        Get-AdbProperty -SerialNumber $serial -Name 'ro.product.model' -Verbose:$VerbosePreference
    }

    $deviceName
}
