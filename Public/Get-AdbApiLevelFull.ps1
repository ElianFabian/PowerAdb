function Get-AdbApiLevelFull {

    [CmdletBinding()]
    [OutputType([float])]
    param (
        [string] $SerialNumber
    )

    $result = Get-AdbProperty -SerialNumber $SerialNumber -Name 'ro.build.version.sdk_full' -Verbose:$VerbosePreference

    if (-not [string]::IsNullOrWhiteSpace($result)) {
        $apiLevel = $result -as [float]
        if ($null -ne $apiLevel) {
            return $apiLevel
        }
    }

    return Get-AdbApiLevel -SerialNumber $SerialNumber -Verbose:$VerbosePreference
}
