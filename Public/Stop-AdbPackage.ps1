function Stop-AdbPackage {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    foreach ($package in $PackageName) {
        $result = Invoke-AdbExpression -DeviceId $DeviceId -Command "shell am force-stop '$package'" -Verbose:$VerbosePreference
        Write-Verbose "Force stop ""$package"": $result"
    }
}
