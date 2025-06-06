function Disable-AdbBluetooth {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [switch] $IgnoreBluetoothFeatureCheck
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 33

    if ($IgnoreBluetoothFeatureCheck -and -not (Test-AdbFeature -DeviceId $DeviceId -Feature 'android.hardware.bluetooth' -Verbose:$false)) {
        Write-Error -Message "Device with id '$DeviceId' does not support Bluetooth." -Category InvalidOperation -ErrorAction Stop
    }

    Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell cmd bluetooth_manager disable' -Verbose:$VerbosePreference
}
