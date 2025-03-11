function Send-AdbMotionEvent {

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [ValidateSet("Down", "Up", "Move")]
        [Parameter(Mandatory)]
        [string] $MotionEvent,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [float] $X,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [float] $Y,

        [Parameter(Mandatory, ParameterSetName = 'Node')]
        [System.Xml.XmlElement] $Node,

        [switch] $DisableCoordinateCheck
    )

    begin {
        $motionEventUpperCase = switch ($MotionEvent) {
            'Down' { 'DOWN' }
            'Up' { 'UP' }
            'Move' { 'MOVE' }
        }
    }

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 29) {
                Write-ApiLevelError -DeviceId $id -ApiLevelLessThan 29
                continue
            }

            switch ($PSCmdlet.ParameterSetName) {
                'Default' {
                    $positionX = $X
                    $positionY = $Y
                }
                'Node' {
                    $bounds = Get-NodeBounds -Node $Node
                    if (-not $bounds) {
                        continue
                    }

                    $positionX = $bounds.CenterX
                    $positionY = $bounds.CenterY
                }
            }

            if (-not $DisableCoordinateCheck) {
                $size = Get-AdbScreenSize -DeviceId $id -Verbose:$false
                $width = $size.Width
                $height = $size.Height
            }
            if (-not $DisableCoordinateCheck -and ($positionX -lt 0.0 -or $positionX -gt $width)) {
                Write-Error "X coordinate in device with id '$id' must be between '0' and '$width', but was '$positionX'"
                continue
            }
            if (-not $DisableCoordinateCheck -and ($positionY -lt 0.0 -or $positionY -gt $height)) {
                Write-Error "Y coordinate in device with id '$id' must be between '0' and '$height', but was '$positionY'"
                continue
            }

            Invoke-AdbExpression -DeviceId $id -Command "shell input motionevent $motionEventUpperCase $positionX $positionY" -Verbose:$VerbosePreference | Out-Null
        }
    }
}
