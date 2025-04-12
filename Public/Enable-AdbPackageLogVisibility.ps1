function Enable-AdbPackageLogVisibility {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 30

    foreach ($package in $PackageName) {
        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell pm log-visibility --enable '$package'" -Verbose:$VerbosePreference
    }
}
