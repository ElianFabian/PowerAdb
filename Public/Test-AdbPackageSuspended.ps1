function Test-AdbPackageSuspended {

    [OutputType([bool[]])]
    [CmdletBinding()]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    foreach ($package in $PackageName) {
        $rawData = Get-AdbPackageInfo -DeviceId $DeviceId -PackageName $PackageName -Raw -Verbose:$VerbosePreference | Out-String

        $rawData.Contains('suspended=true')
    }
}
