function Send-AdbTap {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [float] $X,

        [Parameter(Mandatory)]
        [float] $Y,

        [switch] $DisableCoordinateCheck
    )

    process {
        foreach ($id in $DeviceId) {
            if (-not $DisableCoordinateCheck) {
                $size = Get-AdbDisplaySize -DeviceId $id -Verbose:$false
                $width = $size.Width
                $height = $size.Height
            }
            if (-not $DisableCoordinateCheck -and ($X -lt 0.0 -or $X -gt $width)) {
                Write-Error "X coordinate in device with id '$id' must be between 0 and $width, but was '$X'"
                return
            }
            if (-not $DisableCoordinateCheck -and ($Y -lt 0.0 -or $Y -gt $height)) {
                Write-Error "Y coordinate in device with id '$id' must be between 0 and $height, but was '$Y'"
                return
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell input tap $X $Y" -Verbose:$VerbosePreference | Out-Null
        }
    }
}
