function Get-AdbApiLevel {

    [CmdletBinding()]
    [OutputType([uint[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId | Get-AdbProp -PropertyName "ro.build.version.sdk" -Verbose:$VerbosePreference
        | ForEach-Object {
            [uint] $_
        }
    }
}
