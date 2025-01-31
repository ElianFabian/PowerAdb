function Send-AdbTap {

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [float] $X,

        [Parameter(Mandatory, ParameterSetName = 'Default')]
        [float] $Y,

        [Parameter(Mandatory, ParameterSetName = 'Node')]
        [System.Xml.XmlElement] $Node,

        [switch] $DisableCoordinateCheck
    )

    process {
        foreach ($id in $DeviceId) {
            switch ($PSCmdlet.ParameterSetName) {
                'Default' {
                    $positionX = $X
                    $positionY = $Y
                }
                'Node' {
                    $bounds = $Node.bounds
                    if ($bounds -notmatch '\[\d+,\d+\]\[\d+,\d+\]') {
                        Write-Error "Bounds of node must be in the format '[x1,y1][x2,y2]', but was '$bounds'"
                        return
                    }
                    $x1 = [float] $bounds.Substring(1, $bounds.IndexOf(',') - 1)
                    $y1 = [float] $bounds.Substring($bounds.IndexOf(',') + 1, $bounds.IndexOf(']') - $bounds.IndexOf(',') - 1)
                    $x2 = [float] $bounds.Substring($bounds.LastIndexOf('[') + 1, $bounds.LastIndexOf(',') - $bounds.LastIndexOf('[') - 1)
                    $y2 = [float] $bounds.Substring($bounds.LastIndexOf(',') + 1, $bounds.LastIndexOf(']') - $bounds.LastIndexOf(',') - 1)

                    $positionX = [math]::Round(($x1 + $x2) / 2)
                    $positionY = [math]::Round(($y1 + $y2) / 2)
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

            Invoke-AdbExpression -DeviceId $id -Command "shell input tap $positionX $positionY" -Verbose:$VerbosePreference | Out-Null
        }
    }
}
