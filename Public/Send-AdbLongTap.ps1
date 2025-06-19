function Send-AdbLongTap {

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [float] $X,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [float] $Y,

        [AllowNull()]
        [Nullable[uint32]] $Timeout,

        [Parameter(Mandatory, ParameterSetName = 'Node')]
        [System.Xml.XmlElement] $Node,

        [switch] $EnableCoordinateCheck
    )

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
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 18 -FeatureName "$($MyInvocation.MyCommand.Name) -EnableCoordinateCheck"

        $size = Get-AdbScreenSize -SerialNumber $SerialNumber -Verbose:$false
        $width = $size.Width
        $height = $size.Height

        if ($positionX -lt 0.0 -or $positionX -gt $width) {
            Write-Error "X coordinate in device with serial number '$SerialNumber' must be between 0 and $width, but was '$positionX'" -ErrorAction Stop
        }
        if ($positionY -lt 0.0 -or $positionY -gt $height) {
            Write-Error "Y coordinate in device with serial number '$SerialNumber' must be between 0 and $height, but was '$positionY'" -ErrorAction Stop
        }
    }

    if ($null -ne $Timeout) {
        $longPressTimeout = $Timeout
    }
    else {
        $longPressTimeout = Get-AdbSetting -SerialNumber $SerialNumber -Namespace secure -Name 'long_press_timeout' -Verbose:$false
        if (-not $longPressTimeout) {
            $longPressTimeout = 400
        }
    }

    Send-AdbSwipe -SerialNumber $SerialNumber -X1 $positionX -Y1 $positionY -X2 $positionX -Y2 $positionY -DurationInMilliseconds $longPressTimeout -EnableCoordinateCheck:$EnableCoordinateCheck -Verbose:$VerbosePreference
}
