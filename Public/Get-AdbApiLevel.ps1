function Get-AdbApiLevel {

    [CmdletBinding()]
    [OutputType([uint32[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId | Get-AdbProp -PropertyName "ro.build.version.sdk" -Verbose:$VerbosePreference 2> $null `
        | ForEach-Object { [uint32] $_ }
    }
}
