function Get-AdbSystemServiceName {

    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command 'shell dumpsys -l' `
            | Select-Object -Skip 1 `
            | ForEach-Object { $_.Trim() }
        }
    }
}
