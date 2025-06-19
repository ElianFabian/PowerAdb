function Start-AdbService {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [AllowNull()]
        [object] $UserId,

        [Parameter(Mandatory)]
        [PSCustomObject] $Intent
    )

    $user = Resolve-AdbUser -SerialNumber $SerialNumber -UserId $UserId
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    Assert-ValidIntent -SerialNumber $SerialNumber -Intent $Intent

    $intentArgs = $Intent.ToAdbArguments($SerialNumber)

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell am startservice$userArg$intentArgs" -Verbose:$VerbosePreference
}
