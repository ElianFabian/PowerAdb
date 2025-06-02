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
            # For some permissions this closes the app without throwing an exception. I don't know why.
            $sanitizedPackage = ConvertTo-ValidAdbStringArgument $package
            $sanitizedPermission = ConvertTo-ValidAdbStringArgument $permission
            Invoke-AdbExpression -DeviceId $DeviceId -Command "shell pm revoke $sanitizedPackage $sanitizedPermission" -Verbose:$VerbosePreference
        }
    }
}
