function Get-AdbApiLevel {

    [CmdletBinding()]
    [OutputType([int])]
    param (
        [string] $SerialNumber
    )

    $result = Get-AdbProperty -SerialNumber $SerialNumber -Name 'ro.build.version.sdk' -Verbose:$VerbosePreference

    if ([string]::IsNullOrWhiteSpace($result)) {
        return $null
    }

    $apiLevel = $result -as [int]
    if ($null -ne $apiLevel) {
        return $apiLevel
    }

    return $null
}