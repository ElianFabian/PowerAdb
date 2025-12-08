function Get-AdbBluetoothAddress {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    $value = Get-AdbSetting -SerialNumber $SerialNumber -Namespace secure -Name 'bluetooth_address' -Verbose:$VerbosePreference
    if ($value -ne 'null' -and $value) {
        return $value
    }

    return Get-AdbServiceDump -SerialNumber ZLCQGUPF7TDENZGM -Name bluetooth_manager | Select-Object -Skip 3 -First 1 | ForEach-Object {
        $_.Trim().Replace('address: ', '')
    }
}
