function Disable-AdbWifi {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId
    )

    Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell svc wifi disable' -Verbose:$VerbosePreference
}
