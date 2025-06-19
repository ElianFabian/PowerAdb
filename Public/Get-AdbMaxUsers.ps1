function Get-AdbMaxUsers {

    [OutputType([int])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 28

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command 'shell pm get-max-users' | ForEach-Object {
        [int] $_.SubString('Maximum supported users: '.Length)
    }
}
