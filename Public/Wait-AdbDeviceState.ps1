function Wait-AdbDeviceState {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [ValidateSet("device", "recovery", "rescue", "sideload", "bootloader", "disconnect")]
        [string] $State,

        [ValidateSet("usb", "local", "any")]
        [string] $Transport = "any"
    )

    if ($SerialNumber) {
        $currentState = Get-AdbDeviceState -SerialNumber $SerialNumber -Verbose:$false # -PreventLock
        if ($currentState -eq 'offline') {
            return 'offline'
        }

        Invoke-AdbExpression -SerialNumber $SerialNumber -Command "wait-for-$Transport-$State" -IgnoreExecutionCheck -Verbose:$VerbosePreference
        return
    }

    Invoke-AdbExpression -Command "wait-for-$Transport-$State" -IgnoreExecutionCheck -Verbose:$VerbosePreference
}
