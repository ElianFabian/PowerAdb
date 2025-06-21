function Get-AdbDeviceName {

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string] $SerialNumber
    )

    $serial = Resolve-AdbDevice -SerialNumber $SerialNumber

    $deviceName = if ((Test-AdbEmulator -SerialNumber $serial)) {
        [string] (Invoke-AdbExpression -SerialNumber $serial -Command 'emu avd name' -Verbose:$VerbosePreference | Select-Object -First 1)
    }
    else {
        Get-AdbProperty -SerialNumber $serial -Name 'ro.product.model' -Verbose:$VerbosePreference
    }

    return $deviceName
}
