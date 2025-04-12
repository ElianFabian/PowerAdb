function Get-AdbPackagePid {

    [OutputType([int])]
    [CmdletBinding()]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $PackageName
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 23

    $processId = Invoke-AdbExpression -DeviceId $DeviceId -Command "shell pidof '$PackageName'" -Verbose:$VerbosePreference

    if ($processId) {
        [int] $processId
    }
    else { $null }
}
