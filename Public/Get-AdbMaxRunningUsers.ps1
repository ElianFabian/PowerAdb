function Get-AdbMaxRunningUsers {

    [OutputType([int])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 28

    Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell pm get-max-running-users' | ForEach-Object {
        [int] $_.SubString('Maximum supported running users: '.Length)
    }
}
