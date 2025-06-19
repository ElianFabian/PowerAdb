function Test-BlueStacksEmulator {

    param (
        [string] $SerialNumber
    )

    Test-AdbPath -SerialNumber $SerialNumber -LiteralRemotePath '/mnt/windows/BstSharedFolder'
}
