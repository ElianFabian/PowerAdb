function Start-AdbPackageCrash {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    process {
        foreach ($id in $DeviceId) {
            foreach ($package in $PackageName) {
                $id | Invoke-AdbExpression -Command "shell am crash '$package'" -Verbose:$VerbosePreference
            }
        }
    }
}
