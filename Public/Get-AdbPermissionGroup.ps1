function Get-AdbPermissionGroup {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId | Invoke-AdbExpression -Command "shell pm list permission-groups" `
        | Where-Object { $_ } `
        | ForEach-Object { $_.Replace("permission group:", "") }
    }
}