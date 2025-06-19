function Start-AdbForegroundService {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [AllowNull()]
        [object] $UserId,

        [Parameter(Mandatory)]
        [PSCustomObject] $Intent
    )

    Assert-ValidIntent -SerialNumber $SerialNumber -Intent $Intent

    $apiLevel = Get-AdbApiLevel -SerialNumber $SerialNumber -Verbose:$false
    if ($apiLevel -ge 26) {
        $intentArgs = $Intent.ToAdbArguments($SerialNumber)

        $user = Resolve-AdbUser -SerialNumber $SerialNumber -UserId $UserId
        if ($null -ne $user) {
            $userArg = " --user $user"
        }

        Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell am start-foreground-service$userArg$intentArgs" -Verbose:$VerbosePreference
    }
    else {
        Start-AdbService -SerialNumber $SerialNumber -Intent $Intent -UserId $UserId -Verbose:$VerbosePreference
    }
}
