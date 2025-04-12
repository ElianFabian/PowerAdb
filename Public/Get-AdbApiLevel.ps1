function Get-AdbApiLevel {

    [CmdletBinding()]
    [OutputType([int])]
    param (
        [string] $DeviceId
    )

    $result = Get-AdbProperty -DeviceId $DeviceId -Name 'ro.build.version.sdk' -Verbose:$VerbosePreference
    if ([string]::IsNullOrEmpty($result.Trim())) {
        return $null
    }

    [int] $result
}
