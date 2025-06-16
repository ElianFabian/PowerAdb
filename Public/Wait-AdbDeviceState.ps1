function Wait-AdbDeviceState {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [ValidateSet("device", "recovery", "rescue", "sideload", "bootloader", "disconnect")]
        [string] $State,

        [ValidateSet("usb", "local", "any")]
        [string] $Transport = "any"
    )

    Write-Host "Wait-AdbDeviceState: $DeviceId, $State, $Transport" -Verbose:$VerbosePreference
    if ($DeviceId) {
        $currentState = Get-AdbDeviceState -DeviceId $DeviceId -PreventLock
        if ($currentState -eq 'offline') {
            return 'offline'
        }

        Invoke-AdbExpression -DeviceId $DeviceId -Command "wait-for-$Transport-$State" -Verbose:$VerbosePreference
        return
    }

    Invoke-AdbExpression -NoDevice -Command "wait-for-$Transport-$State" -Verbose:$VerbosePreference
}
