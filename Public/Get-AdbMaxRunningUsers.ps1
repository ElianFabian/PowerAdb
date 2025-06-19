function Get-AdbMaxRunningUsers {

    [OutputType([int])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 28

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command 'shell pm get-max-running-users' | ForEach-Object {
        [int] $_.SubString('Maximum supported running users: '.Length)
    }
}
