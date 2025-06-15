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

    if ($DeviceId) {
        $currentState = Get-AdbDeviceState -DeviceId $DeviceId -PreventLock
        if ($currentState -eq 'offline') {
            return 'offline'
        }

        Invoke-AdbExpression -DeviceId $DeviceId -Command "wait-for-$Transport-$State" -Verbose:$VerbosePreference
    }

    Invoke-AdbExpression -NoDevice -Command "wait-for-$Transport-$State" -Verbose:$VerbosePreference
}
