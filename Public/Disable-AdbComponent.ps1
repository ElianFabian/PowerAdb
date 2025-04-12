function Disable-AdbComponent {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $PackageName,

        [string] $ComponentClassName,

        [AllowNull()]
        [object] $UserId
    )

    $user = Resolve-AdbUser -DeviceId $DeviceId -UserId $UserId
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    $componentArg = if ($ComponentClassName) {
        " '$PackageName/$ComponentClassName'"
    }
    else {
       " '$PackageName'"
    }

    Invoke-AdbExpression -DeviceId $DeviceId -Command "shell pm disable$componentArg$userArg" -Verbose:$VerbosePreference > $null
}
