function Send-AdbSwipe {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [float] $X1,

        [Parameter(Mandatory)]
        [float] $Y1,

        [Parameter(Mandatory)]
        [float] $X2,

        [Parameter(Mandatory)]
        [float] $Y2
    )

    begin {
        # Length of 'Physical size: '
        $physicalSizeStrLength = 15
    }

    process {
        foreach ($id in $DeviceId) {
            $resolution = (Invoke-AdbExpression -DeviceId $id -Command "shell wm size" -Verbose:$false -WarningAction SilentlyContinue).Substring($physicalSizeStrLength)
            $resolutionSplit = [uint[]] $resolution.Split('x')
            $width = $resolutionSplit[0]
            $height = $resolutionSplit[1]

            if ($X1 -lt 0.0 -or $X1 -gt $width) {
                Write-Error "X1 coordinate in device with id '$id' must be between 0 and $width, but was '$X1'"
                return
            }
            if ($Y1 -lt 0.0 -or $Y1 -gt $height) {
                Write-Error "Y1 coordinate in device with id '$id' must be between 0 and $height, but was '$Y1'"
                return
            }
            if ($X2 -lt 0.0 -or $X2 -gt $width) {
                Write-Error "X2 coordinate in device with id '$id' must be between 0 and $width, but was '$X2'"
                return
            }
            if ($Y2 -lt 0.0 -or $Y2 -gt $height) {
                Write-Error "Y2 coordinate in device with id '$id' must be between 0 and $height, but was '$Y2'"
                return
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell input touchscreen swipe $X1 $Y1 $X2 $Y2" | Out-Null
        }
    }
}
