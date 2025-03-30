function Get-AdbPackageApkPath {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName,

        [AllowNull()]
        [Nullable[uint32]] $UserId
    )

    begin {
        if ($null -ne $UserId) {
            $userArg = " --user $UserId"
        }
    }

    process {
        foreach ($id in $DeviceId) {
            foreach ($package in $PackageName) {
                Invoke-AdbExpression -DeviceId $id -Command "shell pm path '$package'$userArg" -Verbose:$VerbosePreference `
                | ForEach-Object { $_.Substring('package:'.Length) }
            }
        }
    }
}
