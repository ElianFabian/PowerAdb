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

    $currentState = Get-AdbDeviceState -SerialNumber $SerialNumber -Verbose:$false # -PreventLock
    if ($currentState -eq 'offline' -and $State -eq 'disconnect') {
        return
    }

    # When the state is 'unauthorized' wait-for-*-disconnect immediately returns, so we manually wait for disconnection.
    if ($currentState -eq 'unauthorized' -and $State -eq 'disconnect') {
        do {
            Start-Sleep -Milliseconds 100
            $currentState = Get-AdbDeviceState -SerialNumber $SerialNumber -Verbose:$false -ErrorAction Ignore
        }
        while ($null -ne $currentState -and $currentState -ne 'offline')
        return
    }

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "wait-for-$Transport-$State" -IgnoreExecutionCheck -Verbose:$VerbosePreference
}
