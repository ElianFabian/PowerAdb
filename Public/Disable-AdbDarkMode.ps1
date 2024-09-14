function Disable-AdbDarkMode {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id
            if ($apiLevel -le 29) {
                Write-Error "Dark theme is only available since API level 29. Device id: '$id', API level: '$apiLevel'"
                continue
            }
            Invoke-AdbExpression -DeviceId $id -Command "shell cmd uimode night no" > $null
        }
    }
}
