function Test-AdbPackageEnabled {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    $disabledPackages = Get-AdbPackage -DeviceId $DeviceId -FilterBy Disabled -Verbose:$false

    foreach ($package in $PackageName) {
        $package -notin $disabledPackages
    }
}
