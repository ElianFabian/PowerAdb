function Get-AdbContentEntryType {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Uri,

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
            $rawResult = Invoke-AdbExpression -DeviceId $id -Command "shell content gettype --uri '$Uri'$userArg" -Verbose:$VerbosePreference

            $rawResult.Substring('Result: '.Length)
        }
    }
}
