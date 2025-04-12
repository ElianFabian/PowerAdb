function Switch-AdbUser {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [int] $Id
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 17

    Invoke-AdbExpression -DeviceId $DeviceId -Command "shell am switch-user $Id" -Verbose:$VerbosePreference > $null
}
