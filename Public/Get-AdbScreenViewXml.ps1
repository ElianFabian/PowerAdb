function Get-AdbScreenViewXml {

    [CmdletBinding()]
    [OutputType([xml])]
    param (
        [string] $DeviceId
    )

    [xml] (Get-AdbScreenViewContent -DeviceId $DeviceId -Verbose:$VerbosePreference)
}
