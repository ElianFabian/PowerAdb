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
        $currentState = Get-AdbDeviceState -DeviceId $DeviceId -Verbose:$false # -PreventLock
        if ($currentState -eq 'offline') {
            return 'offline'
        }

        Invoke-AdbExpression -DeviceId $DeviceId -Command "wait-for-$Transport-$State" -IgnoreExecutionCheck -Verbose:$VerbosePreference
        return
    }

    Invoke-AdbExpression -Command "wait-for-$Transport-$State" -IgnoreExecutionCheck -Verbose:$VerbosePreference
}
