function Get-AdbSystemTimeZone {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [string] $SerialNumber
    )

    Get-AdbProperty -SerialNumber $SerialNumber -Name 'persist.sys.timezone' -Verbose:$VerbosePreference
}
