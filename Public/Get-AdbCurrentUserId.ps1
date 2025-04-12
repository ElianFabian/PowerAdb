function Get-AdbCurrentUserId {

    [OutputType([int])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    $apiLevel = Get-AdbApiLevel -DeviceId $DeviceId -Verbose:$false
    if ($apiLevel -lt 17) {
        return 0
    }

    [int] (Invoke-AdbExpression -DeviceId $DeviceId -Command "shell am get-current-user" -Verbose:$VerbosePreference)
}
