function Set-AdbContentEntry {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $Uri,

        [AllowNull()]
        [object] $UserId,

        [Parameter(Mandatory)]
        [object] $Values,

        [Parameter(Mandatory)]
        [string] $Where
    )

    $user = Resolve-AdbUser -SerialNumber $SerialNumber -UserId $UserId -CurrentUserAsNull
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    $whereArg = " --where $(ConvertTo-ValidAdbStringArgument $Where)"

    $valueAsPsCustomObject = [PSCustomObject] $Values
    Assert-ValidContentEntryValue $valueAsPsCustomObject
    $bindingArgs = ConvertTo-ContentBindingArg $valueAsPsCustomObject

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell content update --uri '$Uri'$userArg$bindingArgs$whereArg" -Verbose:$VerbosePreference
}
