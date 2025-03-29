function Uninstall-AdbPackage {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName,

        [switch] $KeepDataAndCache,

        [AllowNull()]
        [Nullable[uint32]] $UserId,

        [AllowNull()]
        [Nullable[uint32]] $VersionCode
    )

    begin {
        if ($KeepDataAndCache) {
            $keepArg = " -k"
        }
        if ($null -ne $UserId) {
            $userArg = " --user $UserId"
        }
        if ($null -ne $VersionCode) {
            $versionCodeArg = " --versionCode $VersionCode"
        }
    }

    process {
        foreach ($id in $DeviceId) {
            foreach ($package in $PackageName) {
                Invoke-AdbExpression -DeviceId $id -Command "uninstall '$package'$keepArg$userArg$versionCodeArg" -Verbose:$VerbosePreference
            }
        }
    }
}
