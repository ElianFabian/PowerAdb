function Get-AdbCurrentUserId {

    [OutputType([int])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    $apiLevel = Get-AdbApiLevel -SerialNumber $SerialNumber -Verbose:$false
    if ($apiLevel -lt 17) {
        return 0
    }

    [int] (Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell am get-current-user" -Verbose:$VerbosePreference)
}
