function Add-AdbContentEntry {

    [CmdletBinding()]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $Uri,

        [AllowNull()]
        [object] $UserId,

        [Parameter(Mandatory)]
        [object] $Values
    )

    $user = Resolve-AdbUser -DeviceId $DeviceId -UserId $UserId -CurrentUserAsNull
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    $valueAsPsCustomObject = [PSCustomObject] $Values
    Assert-ValidContentEntryValue $valueAsPsCustomObject
    $bindingArgs = ConvertTo-ContentBindingArg $valueAsPsCustomObject

    Invoke-AdbExpression -DeviceId $DeviceId -Command "shell content insert --uri '$Uri'$userArg$bindingArgs" -Verbose:$VerbosePreference
}
