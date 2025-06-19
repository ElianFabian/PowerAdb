function Get-AdbLibrary {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [string] $SerialNumber
    )

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command 'shell pm list libraries' -Verbose:$VerbosePreference `
    | Where-Object { $_ } `
    | ForEach-Object { $_.Replace('library:', '') }
}
