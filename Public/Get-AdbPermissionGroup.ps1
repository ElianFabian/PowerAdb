function Get-AdbPermissionGroup {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [string] $SerialNumber
    )

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command 'shell pm list permission-groups' -Verbose:$VerbosePreference `
    | Where-Object { $_ } `
    | ForEach-Object { $_.Replace('permission group:', '') }
}
