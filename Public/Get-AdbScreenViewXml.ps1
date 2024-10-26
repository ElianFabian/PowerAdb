function Get-AdbScreenViewXml {

    [CmdletBinding()]
    [OutputType([xml[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    return $DeviceId | Get-AdbScreenViewContent -Verbose:$VerbosePreference `
    | ForEach-Object {
        [xml] $_
    }
}
