function Get-AdbDeviceName {

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string] $SerialNumber
    )

    $deviceName = if ((Test-AdbEmulator -SerialNumber $SerialNumber)) {
        Get-AdbEmulatorName -SerialNumber $SerialNumber -Verbose:$VerbosePreference
    }
    else {
        Get-AdbProperty -SerialNumber $SerialNumber -Name 'ro.product.model' -Verbose:$VerbosePreference
    }

    return $deviceName
}
