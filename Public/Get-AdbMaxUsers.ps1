function Get-AdbMaxUsers {

    [OutputType([int])]
    [CmdletBinding()]
    param (
        [string] $DeviceId
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 28

    Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell pm get-max-users' | ForEach-Object {
        [int] $_.SubString('Maximum supported users: '.Length)
    }
}
