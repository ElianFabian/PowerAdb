function Switch-AdbUser {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [int] $Id
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 17

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell am switch-user $Id" -Verbose:$VerbosePreference > $null
}
