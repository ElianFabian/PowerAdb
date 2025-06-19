function Add-AdbContentEntry {

    [CmdletBinding()]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $Uri,

        [AllowNull()]
        [object] $UserId,

        [Parameter(Mandatory)]
        [object] $Values
    )

    $user = Resolve-AdbUser -SerialNumber $SerialNumber -UserId $UserId -CurrentUserAsNull
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    $valueAsPsCustomObject = [PSCustomObject] $Values
    Assert-ValidContentEntryValue $valueAsPsCustomObject
    $bindingArgs = ConvertTo-ContentBindingArg $valueAsPsCustomObject

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell content insert --uri '$Uri'$userArg$bindingArgs" -Verbose:$VerbosePreference
}
