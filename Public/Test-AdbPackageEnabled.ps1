function Test-AdbPackageEnabled {

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    process {
        foreach ($id in $DeviceId) {
            $disabledPackages = Get-AdbPackage -DeviceId $id -FilterBy Disabled -Verbose:$false

            foreach ($package in $PackageName) {
                $package -notin $disabledPackages
            }
        }
    }
}
