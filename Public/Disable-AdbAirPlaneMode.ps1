function Disable-AdbAirPlaneMode {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 28

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command 'shell cmd connectivity airplane-mode disable' -Verbose:$VerbosePreference
}
