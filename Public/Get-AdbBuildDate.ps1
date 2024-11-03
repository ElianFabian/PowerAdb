function Get-AdbBuildDate {

    [CmdletBinding()]
    [OutputType([datetime[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $unixTimeSeconds = Get-AdbProperty -DeviceId $id -Name ro.build.date.utc -Verbose:$VerbosePreference 2> $null
            Get-Date -UnixTimeSeconds $unixTimeSeconds
        }
    }
}
