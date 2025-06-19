function Get-AdbScreenViewXml {

    [CmdletBinding()]
    [OutputType([xml])]
    param (
        [string] $SerialNumber
    )

    [xml] (Get-AdbScreenViewContent -SerialNumber $SerialNumber -Verbose:$VerbosePreference)
}
