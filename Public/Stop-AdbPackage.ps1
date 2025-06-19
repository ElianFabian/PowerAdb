function Stop-AdbPackage {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    foreach ($package in $PackageName) {
        $result = Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell am force-stop '$package'" -Verbose:$VerbosePreference
        Write-Verbose "Force stop ""$package"": $result"
    }
}
