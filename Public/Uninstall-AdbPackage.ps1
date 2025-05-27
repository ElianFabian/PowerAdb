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
    $user = Resolve-AdbUser -DeviceId $DeviceId -UserId $UserId -CurrentUserAsNull -RequireApiLevel 21
    if ($null -ne $user) {
        $userArg = " --user $user"
    }
    if ($null -ne $VersionCode) {
        $versionCodeArg = " --versionCode $VersionCode"
    }

    # TODO: errors like Failure [INSTALL_FAILED_INVALID_APK: Split not found: --user] are returned as a string
    # We should see if there's a clear pattern to check for that and throw it as an exception

    foreach ($package in $PackageName) {
        $sanitizedPackage = ConvertTo-ValidAdbStringArgument $package
        Invoke-AdbExpression -DeviceId $DeviceId -Command "uninstall $sanitizedPackage$keepArg$userArg$versionCodeArg" -Verbose:$VerbosePreference
    }
}
