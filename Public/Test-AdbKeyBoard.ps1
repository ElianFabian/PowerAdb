function Test-AdbKeyBoard {

    [CmdletBinding()]
    [OutputType([bool[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            try {
                Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys input_method" `
                | Select-String -Pattern "mInputShown=(true|false)" `
                | Select-Object -ExpandProperty Matches -First 1 `
                | Select-Object -ExpandProperty Groups -First 2 `
                | Select-Object -ExpandProperty Value -Last 1 `
                | ForEach-Object { [bool]::Parse($_) }
            }
            catch {
                Write-Error "Couldn't determine if the keyboard is open for device with id '$id'"
            }
        }
    }
}
