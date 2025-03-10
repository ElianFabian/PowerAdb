function Stop-AdbPackage {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    process {
        foreach ($id in $DeviceId) {
            foreach ($package in $PackageName) {
                $result = Invoke-AdbExpression -DeviceId $id -Command "shell am force-stop ""$package""" -Verbose:$VerbosePreference
                Write-Verbose "Force stop ""$package"": $result"
            }
        }
    }
}
