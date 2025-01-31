function Send-AdbSwipe {

    [CmdletBinding(SupportsShouldProcess)]
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
        [float] $Y2,

        [long] $DelayInMilliseconds = 0,

        [switch] $DisableCoordinateCheck
    )

    process {
        foreach ($id in $DeviceId) {
            if (-not $DisableCoordinateCheck) {
                $size = Get-AdbScreenSize -DeviceId $id -Verbose:$false
                $width = $size.Width
                $height = $size.Height
            }

            if (-not $DisableCoordinateCheck -and ($X1 -lt 0.0 -or $X1 -gt $width)) {
                Write-Error "X1 coordinate in device with id '$id' must be between 0 and $width, but was '$X1'"
                return
            }
            if (-not $DisableCoordinateCheck -and ($Y1 -lt 0.0 -or $Y1 -gt $height)) {
                Write-Error "Y1 coordinate in device with id '$id' must be between 0 and $height, but was '$Y1'"
                return
            }
            if (-not $DisableCoordinateCheck -and ($X2 -lt 0.0 -or $X2 -gt $width)) {
                Write-Error "X2 coordinate in device with id '$id' must be between 0 and $width, but was '$X2'"
                return
            }
            if (-not $DisableCoordinateCheck -and ($Y2 -lt 0.0 -or $Y2 -gt $height)) {
                Write-Error "Y2 coordinate in device with id '$id' must be between 0 and $height, but was '$Y2'"
                return
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell input touchscreen swipe $X1 $Y1 $X2 $Y2 $DelayInMilliseconds" -Verbose:$VerbosePreference | Out-Null
        }
    }
}
