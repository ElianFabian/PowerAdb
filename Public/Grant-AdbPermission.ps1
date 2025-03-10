function Grant-AdbPermission {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName,

        [Parameter(Mandatory)]
        [string[]] $Permission
    )

    process {
        foreach ($id in $DeviceId) {
            foreach ($package in $PackageName) {
                foreach ($permissionName in $Permission) {
                    $id | Invoke-AdbExpression -Command "shell pm grant '$package' '$permissionName'" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false | Out-Null
                }
            }
        }
    }
}
