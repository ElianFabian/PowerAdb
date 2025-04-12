function Start-AdbPackageCrash {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    foreach ($package in $PackageName) {
        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell am crash '$package'" -Verbose:$VerbosePreference
    }
}
