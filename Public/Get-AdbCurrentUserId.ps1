function Get-AdbCurrentUserId {

    [OutputType([int[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $DeviceId
    )

    foreach ($id in $DeviceId) {
        Invoke-AdbExpression -DeviceId $id -Command "shell am get-current-user" -Verbose:$VerbosePreference | ForEach-Object {
            [int] $_
        }
    }
}
