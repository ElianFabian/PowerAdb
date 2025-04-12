function Get-AdbSystemTimeZone {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [string] $DeviceId
    )

    Get-AdbProperty -DeviceId $DeviceId -Name 'persist.sys.timezone' -Verbose:$VerbosePreference
}
