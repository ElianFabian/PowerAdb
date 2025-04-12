function ConvertTo-AdbIntentUri {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [PSCustomObject] $Intent
    )

    $intentArgs = $element.ToAdbArguments($DeviceId)

    Invoke-AdbExpression -DeviceId $DeviceId -Command "shell am to-intent-uri $intentArgs" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false
}
