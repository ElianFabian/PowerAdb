function Enable-AdbPackageLogVisibility {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 30

    foreach ($package in $PackageName) {
        Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell pm log-visibility --enable '$package'" -Verbose:$VerbosePreference
    }
}
