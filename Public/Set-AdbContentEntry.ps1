function Set-AdbContentEntry {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Uri,

        [AllowNull()]
        [object] $UserId,

        [Parameter(Mandatory)]
        [object] $Values,

        [Parameter(Mandatory)]
        [string] $Where
    )

    $user = Resolve-AdbUser -DeviceId $DeviceId -UserId $UserId -CurrentUserAsNull
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    $whereArg = " --where $(ConvertTo-ValidAdbStringArgument $Where)"

    $valueAsPsCustomObject = [PSCustomObject] $Values
    Assert-ValidContentEntryValue $valueAsPsCustomObject
    $bindingArgs = ConvertTo-ContentBindingArg $valueAsPsCustomObject

    Invoke-AdbExpression -DeviceId $DeviceId -Command "shell content update --uri '$Uri'$userArg$bindingArgs$whereArg" -Verbose:$VerbosePreference
}
