function Get-AdbLibrary {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        $DeviceId | Invoke-AdbExpression -Command "shell pm list libraries" `
        | Where-Object { $_ } `
        | ForEach-Object { $_.Replace("library:", "") }
    }
}
