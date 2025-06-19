function Get-AdbApiLevel {

    [CmdletBinding()]
    [OutputType([int])]
    param (
        [string] $SerialNumber
    )

    $result = Get-AdbProperty -SerialNumber $SerialNumber -Name 'ro.build.version.sdk' -Verbose:$VerbosePreference
    if ([string]::IsNullOrEmpty($result.Trim())) {
        return $null
    }

    [int] $result
}
