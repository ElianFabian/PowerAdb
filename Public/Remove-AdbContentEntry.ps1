function Remove-AdbContentEntry {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $Uri,

        [AllowNull()]
        [object] $UserId,

        [Parameter(Mandatory)]
        [string] $Where
    )

    $user = Resolve-AdbUser -SerialNumber $SerialNumber -UserId $UserId -CurrentUserAsNull
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    $whereArg = " --where $(ConvertTo-ValidAdbStringArgument $Where)"

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell content delete --uri '$Uri' $userArg$whereArg" -Verbose:$VerbosePreference
}
