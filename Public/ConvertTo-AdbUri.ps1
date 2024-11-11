function ConvertTo-AdbUri {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $Intent
    )

    $intentArgs = $Intent.ToAdbArguments()

    Invoke-AdbExpression -Command "shell am to-uri $intentArgs" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false
}
