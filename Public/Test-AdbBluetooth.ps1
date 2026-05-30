function Test-AdbBluetooth {

    [OutputType([bool])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [switch] $IgnoreBluetoothFeatureCheck
    )

    if (-not $IgnoreBluetoothFeatureCheck -and -not (Test-AdbFeature -SerialNumber $SerialNumber -Feature 'android.hardware.bluetooth' -Verbose:$false)) {
        Write-Error -Message "Device with serial number '$SerialNumber' does not support Bluetooth." -Category InvalidOperation -ErrorAction Stop
    }

    do {
        # TODO: There is also the state of BLE_TURNING_ON and BLE_TURNING_OFF, so maybe we could create a differente function
        # that returns the code for all the states.
        $result = (Get-AdbServiceDump -SerialNumber $SerialNumber -Name bluetooth_manager | Select-Object -First 10) -join "`n"
    }
    while ($result.Contains('TURNING_OFF') -or $result.Contains('TURNING_ON'))

    switch -regex ($result) {
        'state\s*:\s*on' { $true }
        'state\s*:\s*off' { $false }
        default {
            Write-Error -Message "Unknown state: $_" -ErrorAction Stop
        }
    }
}
