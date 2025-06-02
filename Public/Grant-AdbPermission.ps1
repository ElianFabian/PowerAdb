function Grant-AdbPermission {

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
            $sanitizedPackage = ConvertTo-ValidAdbStringArgument $package
            $sanitizedPermission = ConvertTo-ValidAdbStringArgument $permission
            Invoke-AdbExpression -DeviceId $DeviceId -Command "shell pm grant $sanitizedPackage $sanitizedPermission" -Verbose:$VerbosePreference
        }
    }
}
