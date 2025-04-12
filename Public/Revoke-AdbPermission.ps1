function Revoke-AdbPermission {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName,

        [Parameter(Mandatory)]
        [string[]] $PermissionName
    )

    foreach ($package in $PackageName) {
        foreach ($permission in $PermissionName) {
            Invoke-AdbExpression -DeviceId $DeviceId -Command "shell pm revoke '$package' '$permission'" -Verbose:$VerbosePreference
        }
    }
}
