function Get-AdbSerialNumber {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $DeviceId
    )

    Invoke-AdbExpression -DeviceId $DeviceId -Command "get-serialno" -Verbose:$VerbosePreference
}
