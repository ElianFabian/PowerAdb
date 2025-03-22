function Get-AdbApiLevel {

    [CmdletBinding()]
    [OutputType([uint32[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            Get-AdbProperty -DeviceId $id -Name 'ro.build.version.sdk' -Verbose:$VerbosePreference 2> $null
        }
    }
}
