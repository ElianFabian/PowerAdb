function Test-AdbPackageSuspended {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    foreach ($package in $PackageName) {
        $rawData = Get-AdbPackageInfo -SerialNumber $SerialNumber -PackageName $PackageName -Raw -Verbose:$VerbosePreference | Out-String

        $rawData.Contains('suspended=true')
    }
}
