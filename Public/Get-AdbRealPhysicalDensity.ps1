function Get-AdbRealPhysicalDensity {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id
            if ($apiLevel -lt 17) {
                Write-Error "Get real physical density is not supported for device with id '$id' with API level of '$apiLevel'. Only API levels 17 and above are supported."
                continue
            }
            if ($apiLevel -lt 30) {
                Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys display"`
                | Select-String -Pattern "(-?\d+(\.\d+)?) dpi" `
                | ForEach-Object { $_.Matches } `
                | Select-Object -First 1 `
                | ForEach-Object { [int] $_.Groups[1].Value }
                continue
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys display"`
            | Select-String -Pattern "xDpi=(-?\d+(\.\d+)?)" `
            | ForEach-Object { $_.Matches } `
            | Select-Object -First 1 `
            | ForEach-Object { [float] $_.Groups[1].Value }
        }
    }
}
