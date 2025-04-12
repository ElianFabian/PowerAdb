function Get-AdbPermissionGroup {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [string] $DeviceId
    )

    Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell pm list permission-groups' -Verbose:$VerbosePreference `
    | Where-Object { $_ } `
    | ForEach-Object { $_.Replace('permission group:', '') }
}
