function Get-AdbDevice {

    [CmdletBinding()]
    [OutputType([string[]])]
    param ()

    Write-Verbose "adb devices"

    adb devices `
    | Select-Object -Skip 1 `
    | Select-Object -SkipLast 1 `
    | ForEach-Object { $_.Split("`t")[0] }
}
