function Remove-AdbUser {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [int[]] $Id
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 17

    foreach ($userId in $Id) {
        Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell pm remove-user $userId" -Verbose:$VerbosePreference > $null
    }
}
