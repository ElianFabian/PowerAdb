function Get-AdbBluetoothAddress {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    Get-AdbSetting -DeviceId $DeviceId -Namespace secure -Name 'bluetooth_address' -Verbose:$VerbosePreference
}
