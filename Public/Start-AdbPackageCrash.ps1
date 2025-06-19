function Start-AdbPackageCrash {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    foreach ($package in $PackageName) {
        Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell am crash '$package'" -Verbose:$VerbosePreference
    }
}
