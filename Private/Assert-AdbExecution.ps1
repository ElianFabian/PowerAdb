function Assert-AdbExecution {

    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    $availableDevices = Get-AdbDevice -Verbose:$false
    if ($availableDevices.Count -eq 0) {
        throw [AdbException]::new('No device connected')
    }
    if ($SerialNumber -and $SerialNumber -notin $availableDevices) {
        throw [AdbException]::new("There's no device with serial number '$SerialNumber' connected")
    }
    if (-not $SerialNumber -and $availableDevices.Count -gt 1) {
        throw [AdbException]::new("More than one device/emulator, please specify the device id")
    }
}
