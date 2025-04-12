function Start-AdbService {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [AllowNull()]
        [object] $UserId,

        [Parameter(Mandatory)]
        [PSCustomObject] $Intent
    )

    $user = Resolve-AdbUser -DeviceId $DeviceId -UserId $UserId
    if ($null -ne $user) {
        $userArg = " --user $user"
    }

    Assert-ValidIntent -DeviceId $DeviceId -Intent $Intent

    $intentArgs = $Intent.ToAdbArguments($DeviceId)

    Invoke-AdbExpression -DeviceId $DeviceId -Command "shell am startservice$userArg$intentArgs" -Verbose:$VerbosePreference
}
