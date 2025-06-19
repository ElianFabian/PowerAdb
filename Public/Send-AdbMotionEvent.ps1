function Send-AdbMotionEvent {

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param (
        [string] $SerialNumber,

        [ValidateSet("Down", "Up", "Move")]
        [Parameter(Mandatory)]
        [string] $MotionEvent,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [float] $X,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [float] $Y,

        [Parameter(Mandatory, ParameterSetName = 'Node')]
        [System.Xml.XmlElement] $Node,

        [switch] $EnableCoordinateCheck
    )

    Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 29

    $motionEventUpperCase = switch ($MotionEvent) {
        'Down' { 'DOWN' }
        'Up' { 'UP' }
        'Move' { 'MOVE' }
    }

    switch ($PSCmdlet.ParameterSetName) {
        'Default' {
            $positionX = $X
            $positionY = $Y
        }
        'Node' {
            $bounds = Get-ScreenNodeBounds -Node $Node
            if (-not $bounds) {
                continue
            }

            $positionX = $bounds.CenterX
            $positionY = $bounds.CenterY
        }
    }

    if ($EnableCoordinateCheck) {
        $size = Get-AdbScreenSize -SerialNumber $SerialNumber -Verbose:$false
        $width = $size.Width
        $height = $size.Height

        if ($positionX -lt 0.0 -or $positionX -gt $width) {
            Write-Error "X coordinate in device with serial number '$SerialNumber' must be between '0' and '$width', but was '$positionX'" -ErrorAction Stop
        }
        if ($positionY -lt 0.0 -or $positionY -gt $height) {
            Write-Error "Y coordinate in device with serial number '$SerialNumber' must be between '0' and '$height', but was '$positionY'" -ErrorAction Stop
        }
    }

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell input motionevent $motionEventUpperCase $positionX $positionY" -Verbose:$VerbosePreference > $null
}
