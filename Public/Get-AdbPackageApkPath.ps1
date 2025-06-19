function Get-AdbPackageApkPath {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string[]] $PackageName,

        [AllowNull()]
        [object] $UserId
    )

    $user = Resolve-AdbUser -SerialNumber $SerialNumber -UserId $UserId
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    foreach ($package in $PackageName) {
        Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell pm path '$package'$userArg" -Verbose:$VerbosePreference `
        | ForEach-Object { $_.Substring('package:'.Length) }
    }
}
