function Get-AdbContentEntryType {

    [CmdletBinding()]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $Uri,

        [AllowNull()]
        [object] $UserId
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 26

    $user = Resolve-AdbUser -SerialNumber $SerialNumber -UserId $UserId -CurrentUserAsNull
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    $rawResult = Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell content gettype --uri '$Uri'$userArg" -Verbose:$VerbosePreference

    $rawResult.Substring('Result: '.Length)
}
