function Enable-AdbDarkMode {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id
            if ($apiLevel -le 29) {
                Write-Error "Operation not supported for device with id: '$id' and API level '$apiLevel'. Dark theme is only available since API level 29"
                continue
            }
            Invoke-AdbExpression -DeviceId $id -Command "shell cmd uimode night yes" > $null
        }
    }
}
