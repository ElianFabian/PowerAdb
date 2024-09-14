function Grant-AdbPermission {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $ApplicationId,

        [Parameter(Mandatory)]
        [string[]] $Permission
    )

    process {
        foreach ($id in $DeviceId) {
            foreach ($appId in $ApplicationId) {
                foreach ($permissionName in $Permission) {
                    $id | Invoke-AdbExpression -Command "shell pm grant '$appId' '$permissionName'" -Verbose:$VerbosePreference | Out-Null
                }
            }
        }
    }
}
