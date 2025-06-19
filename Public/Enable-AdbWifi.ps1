function Enable-AdbWifi {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber
    )

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command 'shell svc wifi enable' -Verbose:$VerbosePreference
}
