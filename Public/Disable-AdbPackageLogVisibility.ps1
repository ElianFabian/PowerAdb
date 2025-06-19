function Disable-AdbPackageLogVisibility {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    foreach ($package in $PackageName) {
        Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell pm log-visibility --disable '$package'" -Verbose:$VerbosePreference
    }
}
