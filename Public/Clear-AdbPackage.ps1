function Clear-AdbPackage {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [AllowNull()]
        [Nullable[uint32]] $UserId,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    begin {
        if ($null -ne $UserId) {
            $userArg = " --user $UserId"
        }
    }

    process {
        foreach ($id in $DeviceId) {
            foreach ($package in $PackageName) {
                $result = Invoke-AdbExpression -DeviceId $id -Command "shell pm clear$userArg $package" -Verbose:$VerbosePreference
                Write-Verbose "Clear data in device with id '$id' from '$package': $result"
            }
        }
    }
}
