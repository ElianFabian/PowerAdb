function Disable-AdbPackage {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $PackageName,

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
            Invoke-AdbExpression -DeviceId $id -Command "shell pm disable $PackageName$userArg" -Verbose:$VerbosePreference > $null
        }
    }
}
