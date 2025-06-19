function Disable-AdbComponent {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $PackageName,

        [string] $ComponentClassName,

        [AllowNull()]
        [object] $UserId
    )

    $user = Resolve-AdbUser -SerialNumber $SerialNumber -UserId $UserId
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    $componentArg = if ($ComponentClassName) {
        " '$PackageName/$ComponentClassName'"
    }
    else {
       " '$PackageName'"
    }

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell pm disable$componentArg$userArg" -Verbose:$VerbosePreference > $null
}
