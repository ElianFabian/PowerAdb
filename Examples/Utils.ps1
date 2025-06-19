function Test-BlueStacksEmulator {

    param (
        [string] $DeviceId
    )

    Test-AdbPath -DeviceId $DeviceId -LiteralRemotePath '/mnt/windows/BstSharedFolder'
}
