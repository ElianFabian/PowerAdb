function Disable-AdbWifi {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber
    )

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command 'shell svc wifi disable' -Verbose:$VerbosePreference
}
