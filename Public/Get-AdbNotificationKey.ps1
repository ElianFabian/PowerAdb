function Get-AdbNotificationKey {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 24

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command 'shell cmd notification list' -Verbose:$VerbosePreference
}
