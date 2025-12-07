function Get-AdbBluetoothState {

    [OutputType([bool])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [switch] $IgnoreBluetoothFeatureCheck
    )

    if (-not $IgnoreBluetoothFeatureCheck -and -not (Test-AdbFeature -SerialNumber $SerialNumber -Feature 'android.hardware.bluetooth' -Verbose:$false)) {
        Write-Error -Message "Device with serial number '$SerialNumber' does not support Bluetooth." -Category InvalidOperation -ErrorAction Stop
    }

    # States: (there may be more than this)
    # - ON
    # - TURNING_ON
    # - OFF
    # - TURNING_OFF
    # - BLE_TURNING_ON
    # - BLE_TURNING_OFF
    return Get-AdbServiceDump -SerialNumber $SerialNumber -Name bluetooth_manager | Select-Object -Skip 2 -First 1 | ForEach-Object {
        $_.Trim().Replace('state: ', '')
    }
}
