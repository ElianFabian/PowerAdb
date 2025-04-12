function Disable-AdbPackageLogVisibility {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    foreach ($package in $PackageName) {
        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell pm log-visibility --disable '$package'" -Verbose:$VerbosePreference
    }
}
