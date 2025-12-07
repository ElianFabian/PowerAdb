function Get-AdbBluetoothName {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    $value = Get-AdbSetting -SerialNumber $SerialNumber -Namespace secure -Name 'bluetooth_name' -Verbose:$VerbosePreference
    if ($value -ne 'null' -and -not $value) {
        return $value
    }

    return Get-AdbServiceDump -SerialNumber $SerialNumber -Name bluetooth_manager | Select-Object -Skip 4 -First 1 | ForEach-Object {
        $_.Trim().Replace('name: ', '')
    }
}
