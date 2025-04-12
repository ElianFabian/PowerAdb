function Start-AdbForegroundService {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [AllowNull()]
        [object] $UserId,

        [Parameter(Mandatory)]
        [PSCustomObject] $Intent
    )

    Assert-ValidIntent -DeviceId $DeviceId -Intent $Intent

    $apiLevel = Get-AdbApiLevel -DeviceId $DeviceId -Verbose:$false
    if ($apiLevel -ge 26) {
        $intentArgs = $Intent.ToAdbArguments($DeviceId)

        $user = Resolve-AdbUser -DeviceId $DeviceId -UserId $UserId
        if ($null -ne $user) {
            $userArg = " --user $user"
        }

        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell am start-foreground-service$userArg$intentArgs" -Verbose:$VerbosePreference
    }
    else {
        Start-AdbService -DeviceId $DeviceId -Intent $Intent -UserId $UserId -Verbose:$VerbosePreference
    }
}
