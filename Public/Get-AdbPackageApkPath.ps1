function Get-AdbPackageApkPath {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName,

        [AllowNull()]
        [object] $UserId
    )

    $user = Resolve-AdbUser -DeviceId $DeviceId -UserId $UserId
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    foreach ($package in $PackageName) {
        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell pm path '$package'$userArg" -Verbose:$VerbosePreference `
        | ForEach-Object { $_.Substring('package:'.Length) }
    }
}
