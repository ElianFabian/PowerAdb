function Test-AdbPackageEnabled {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    $disabledPackages = Get-AdbPackage -SerialNumber $SerialNumber -FilterBy Disabled -Verbose:$false

    foreach ($package in $PackageName) {
        $package -notin $disabledPackages
    }
}
