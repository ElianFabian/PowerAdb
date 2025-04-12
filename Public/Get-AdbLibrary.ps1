function Get-AdbLibrary {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [string] $DeviceId
    )

    Invoke-AdbExpression -DeviceId $DeviceId -Command 'shell pm list libraries' -Verbose:$VerbosePreference `
    | Where-Object { $_ } `
    | ForEach-Object { $_.Replace('library:', '') }
}
