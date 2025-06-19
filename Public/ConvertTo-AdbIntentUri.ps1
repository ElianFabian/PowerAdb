function ConvertTo-AdbIntentUri {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [PSCustomObject] $Intent
    )

    $intentArgs = $element.ToAdbArguments($SerialNumber)

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell am to-intent-uri $intentArgs" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false
}
