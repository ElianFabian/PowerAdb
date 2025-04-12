function ConvertTo-AdbUri {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [PSCustomObject] $Intent
    )

    $intentArgs = $element.ToAdbArguments($DeviceId)

    Invoke-AdbExpression -DeviceId $DeviceId -Command "shell am to-uri $intentArgs" -Verbose:$VerbosePreference
}
