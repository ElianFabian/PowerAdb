function Get-AdbMaxRunningUsers {

    [OutputType([uint32])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command 'shell pm get-max-running-users' | ForEach-Object {
                [uint32] $_.SubString('Maximum supported running users: '.Length)
            }
        }
    }
}
