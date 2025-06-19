function Get-AdbBluetoothAddress {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    Get-AdbSetting -SerialNumber $SerialNumber -Namespace secure -Name 'bluetooth_address' -Verbose:$VerbosePreference
}
