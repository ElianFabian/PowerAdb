function Get-AdbContentEntryType {

    [CmdletBinding()]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Uri,

        [AllowNull()]
        [object] $UserId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 26

    $user = Resolve-AdbUser -DeviceId $DeviceId -UserId $UserId -CurrentUserAsNull
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    $rawResult = Invoke-AdbExpression -DeviceId $DeviceId -Command "shell content gettype --uri '$Uri'$userArg" -Verbose:$VerbosePreference

    $rawResult.Substring('Result: '.Length)
}
