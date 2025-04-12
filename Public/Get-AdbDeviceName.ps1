function Get-AdbDeviceName {

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string] $DeviceId
    )

    $device = $DeviceId
    $availableDevices = Get-AdbDevice
    if ($availableDevices.Count -eq 1 -and -not $device) {
        $device = $availableDevices
    }

    $deviceName = if ((Test-AdbEmulator -DeviceId $device)) {
        [string] (Invoke-AdbExpression -DeviceId $device -Command 'emu avd name' -Verbose:$VerbosePreference | Select-Object -First 1)
    }
    else {
        Get-AdbProperty -DeviceId $device -Name 'ro.product.model' -Verbose:$VerbosePreference
    }

    $deviceName
}
