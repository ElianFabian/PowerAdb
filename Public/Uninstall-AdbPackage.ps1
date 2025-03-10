function Uninstall-AdbPackage {

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
                Invoke-AdbExpression -DeviceId $id -Command "uninstall '$package'" -Verbose:$VerbosePreference
            }
        }
    }
}
