function Send-AdbTap {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [float] $X,

        [Parameter(Mandatory)]
        [float] $Y
    )

    process {
        foreach ($id in $DeviceId) {
            $width, $height = Get-AdbDisplaySize -DeviceId $id -Verbose:$false

            if ($X -lt 0.0 -or $X -gt $width) {
                Write-Error "X coordinate in device with id '$id' must be between 0 and $width, but was '$X'"
                return
            }
            if ($Y -lt 0.0 -or $Y -gt $height) {
                Write-Error "Y coordinate in device with id '$id' must be between 0 and $height, but was '$Y'"
                return
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell input tap $X $Y" | Out-Null
        }
    }
}
