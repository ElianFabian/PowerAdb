function Start-AdbService {

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
            Invoke-AdbExpression -DeviceId $id -Command "shell am startservice $intentArgs" -Verbose:$VerbosePreference
        }
    }
}
