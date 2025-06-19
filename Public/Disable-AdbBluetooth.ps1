function Disable-AdbBluetooth {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [switch] $IgnoreBluetoothFeatureCheck
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 33

    if (-not $IgnoreBluetoothFeatureCheck -and -not (Test-AdbFeature -SerialNumber $SerialNumber -Feature 'android.hardware.bluetooth' -Verbose:$false)) {
        Write-Error -Message "Device with serial number '$SerialNumber' does not support Bluetooth." -Category InvalidOperation -ErrorAction Stop
    }

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command 'shell cmd bluetooth_manager disable' -Verbose:$VerbosePreference
}
