function Enable-AdbWifi {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId
    )

    Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell svc wifi enable' -Verbose:$VerbosePreference
}
