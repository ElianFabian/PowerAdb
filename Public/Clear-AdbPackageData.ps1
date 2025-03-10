function Clear-AdbPackageData {

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
                $result = Invoke-AdbExpression -DeviceId $id -Command "shell pm clear $package" -Verbose:$VerbosePreference
                Write-Verbose "Clear data in device with id '$id' from '$package': $result"
            }
        }
    }
}
