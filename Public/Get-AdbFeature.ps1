function Get-AdbFeature {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId | Invoke-AdbExpression -Command "shell pm list features" -Verbose:$VerbosePreference `
        | Where-Object { $_ } `
        | ForEach-Object { $_.Replace("feature:", "") }
    }
}
