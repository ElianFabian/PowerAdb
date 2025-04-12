function Remove-AdbUser {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [int[]] $Id
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 17

    foreach ($userId in $Id) {
        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell pm remove-user $userId" -Verbose:$VerbosePreference > $null
    }
}
