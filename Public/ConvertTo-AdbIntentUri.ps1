function ConvertTo-AdbIntentUri {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject] $Intent
    )

    $intentArgs = $Intent.ToAdbArguments()

    Invoke-AdbExpression -Command "shell am to-intent-uri $intentArgs" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false
}
