function ConvertTo-AdbIntentUri {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [PSCustomObject] $Intent
    )

    begin {
        $intentArgs = $element.ToAdbArguments()
    }

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell am to-intent-uri $intentArgs" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false
        }
    }
}
