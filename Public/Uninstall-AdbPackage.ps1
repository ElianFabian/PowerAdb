function Uninstall-AdbPackage {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName,

        [switch] $KeepDataAndCache,

        [AllowNull()]
        [object] $UserId,

        [AllowNull()]
        [Nullable[int]] $VersionCode
    )

    if ($KeepDataAndCache) {
        $keepArg = " -k"
    }
    $user = Resolve-AdbUser -DeviceId $DeviceId -UserId $UserId
    if ($null -ne $user) {
        $userArg = " --user $user"
    }
    if ($null -ne $VersionCode) {
        $versionCodeArg = " --versionCode $VersionCode"
    }

    foreach ($package in $PackageName) {
        Invoke-AdbExpression -DeviceId $DeviceId -Command "uninstall '$package'$keepArg$userArg$versionCodeArg" -Verbose:$VerbosePreference
    }
}
