function Grant-AdbPermission {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string[]] $PackageName,

        [Parameter(Mandatory)]
        [string[]] $PermissionName
    )

    foreach ($package in $PackageName) {
        foreach ($permission in $PermissionName) {
            $sanitizedPackage = ConvertTo-ValidAdbStringArgument $package
            $sanitizedPermission = ConvertTo-ValidAdbStringArgument $permission
            Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell pm grant $sanitizedPackage $sanitizedPermission" -Verbose:$VerbosePreference
        }
    }
}
