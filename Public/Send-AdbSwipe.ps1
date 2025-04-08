function Send-AdbSwipe {

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [float] $X1,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [float] $Y1,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [float] $X2,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [float] $Y2,

        [Parameter(Mandatory, ParameterSetName = 'Node')]
        [System.Xml.XmlElement] $Node1,

        [Parameter(Mandatory, ParameterSetName = 'Node')]
        [System.Xml.XmlElement] $Node2,

        [long] $DurationInMilliseconds = 0,

        [switch] $DisableCoordinateCheck
    )

    process {
        foreach ($id in $DeviceId) {
            if (-not $DisableCoordinateCheck) {
                $size = Get-AdbScreenSize -DeviceId $id -Verbose:$false
                $width = $size.Width
                $height = $size.Height
            }

            switch ($PSCmdlet.ParameterSetName) {
                'Default' {
                    $positionX1 = $X1
                    $positionY1 = $Y1
                    $positionX2 = $X2
                    $positionY2 = $Y2
                }
                'Node' {
                    $bounds1 = Get-ScreenNodeBounds -Node $Node1
                    if (-not $bounds1) {
                        continue
                    }
                    $bounds2 = Get-ScreenNodeBounds -Node $Node2
                    if (-not $bounds2) {
                        continue
                    }

                    $positionX1 = $bounds1.CenterX
                    $positionY1 = $bounds1.CenterY
                    $positionX2 = $bounds2.CenterX
                    $positionY2 = $bounds2.CenterY
                }
            }

            if (-not $DisableCoordinateCheck -and ($positionX1 -lt 0.0 -or $positionX1 -gt $width)) {
                Write-Error "X1 coordinate in device with id '$id' must be between 0 and $width, but was '$positionX1'"
                return
            }
            if (-not $DisableCoordinateCheck -and ($positionY1 -lt 0.0 -or $positionY1 -gt $height)) {
                Write-Error "Y1 coordinate in device with id '$id' must be between 0 and $height, but was '$positionY1'"
                return
            }
            if (-not $DisableCoordinateCheck -and ($positionX2 -lt 0.0 -or $positionX2 -gt $width)) {
                Write-Error "X2 coordinate in device with id '$id' must be between 0 and $width, but was '$positionX2'"
                return
            }
            if (-not $DisableCoordinateCheck -and ($positionY2 -lt 0.0 -or $positionY2 -gt $height)) {
                Write-Error "Y2 coordinate in device with id '$id' must be between 0 and $height, but was '$positionY2'"
                return
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell input touchscreen swipe $positionX1 $positionY1 $positionX2 $positionY2 $DurationInMilliseconds" -Verbose:$VerbosePreference | Out-Null
        }
    }
}
