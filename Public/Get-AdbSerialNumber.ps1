function Get-AdbSerialNumber {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $SerialNumber
    )

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "get-serialno" -Verbose:$VerbosePreference
}
