function Get-AdbBootCount {

    [CmdletBinding()]
    [OutputType([uint32[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            [uint32] (Get-AdbSetting -DeviceId $id -Namespace Global -Key 'boot_count' -Verbose:$VerbosePreference)
        }
    }
}
