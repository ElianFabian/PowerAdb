function Remove-AdbContentEntry {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Uri,

        [AllowNull()]
        [object] $UserId,

        [Parameter(Mandatory)]
        [string] $Where
    )

    $user = Resolve-AdbUser -DeviceId $DeviceId -UserId $UserId -CurrentUserAsNull
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    $whereArg = " --where $(ConvertTo-ValidAdbStringArgument $Where)"

    Invoke-AdbExpression -DeviceId $DeviceId -Command "shell content delete --uri '$Uri' $userArg$whereArg" -Verbose:$VerbosePreference
}
