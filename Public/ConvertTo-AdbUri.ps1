function ConvertTo-AdbUri {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [PSCustomObject] $Intent
    )

    $intentArgs = $element.ToAdbArguments($SerialNumber)

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell am to-uri $intentArgs" -Verbose:$VerbosePreference
}
