function Start-AdbForegroundService {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [PSCustomObject] $Intent
    )

    begin {
        $intentArgs = $Intent.ToAdbArguments()
    }

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -ge 26) {
                Invoke-AdbExpression -DeviceId $id -Command "shell am start-foreground-service $intentArgs" -Verbose:$VerbosePreference
            }
            else {
                Start-AdbService -DeviceId $id -Intent $Intent
            }
        }
    }
}
