function Get-AdbDeviceType {

    [OutputType([string])]
    [CmdletBinding(SupportsShouldProcess)]   
    param (
        [Parameter(Mandatory)]
        [string] $SerialNumber
    )

    if ($SerialNumber.StartsWith('emulator-')) {
        return 'emulator'
    }
    if ($SerialNumber -match '^[\w-]+:[0-9]+$') {
        return 'physical-wifi-legacy'
    }
    if ($SerialNumber -match '^[\w-]+$') {
        return 'physical-usb'
    }
    if ($SerialNumber -match '^[\w-]+._adb-tls-connect._tcp$') {
        return 'physical-wifi-mdns'
    }
    if ($SerialNumber -match '^localhost:[0-9]+$') {
        # TODO: we could try to find a better way to distinguish between a physical remote device
        return 'physical-remote-or-bluestacks'
    }

    return 'unknown'
}
