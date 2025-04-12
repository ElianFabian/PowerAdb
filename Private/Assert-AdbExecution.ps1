function Assert-AdbExecution {

    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    $availableDevices = Get-AdbDevice -Verbose:$false
    if ($availableDevices.Count -eq 0) {
        throw [AdbException]::new('No device connected')
    }
    if ($DeviceId -and $DeviceId -notin $availableDevices) {
        throw [AdbException]::new("There's no device with id '$DeviceId' connected")
    }
    if (-not $DeviceId -and $availableDevices.Count -gt 1) {
        throw [AdbException]::new("More than one device/emulator, please specify the device id")
    }
}
