function Get-AdbPackagePid {

    [OutputType([int])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $PackageName
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 23

    $processId = Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell pidof '$PackageName'" -Verbose:$VerbosePreference

    if ($processId) {
        [int] $processId
    }
    else { $null }
}
