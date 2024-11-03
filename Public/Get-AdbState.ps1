function Get-AdbState {

    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId | Invoke-AdbExpression -Command "get-state" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false
    }
}
