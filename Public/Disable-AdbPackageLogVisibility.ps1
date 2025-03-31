function Disable-AdbPackageLogVisibility {

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
                Invoke-AdbExpression -DeviceId $id -Command "shell pm log-visibility --disable '$package'" -Verbose:$VerbosePreference
            }
        }
    }
}
