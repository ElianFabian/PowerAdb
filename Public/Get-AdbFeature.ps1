function Get-AdbFeature {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId | Invoke-AdbExpression -Command "shell pm list features" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
        | Where-Object { $_ } `
        | ForEach-Object { $_.Replace("feature:", "") }
    }
}
