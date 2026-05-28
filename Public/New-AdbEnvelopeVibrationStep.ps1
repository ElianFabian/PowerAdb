function New-AdbEnvelopeVibrationStep {

    [OutputType([PSCustomObject])]
    [CmdletBinding(DefaultParameterSetName = 'Standard')]
    param (
        [Parameter(Mandatory, Position = 0)]
        [int] $DurationMilliseconds,

        [Parameter(Mandatory, ParameterSetName = 'Standard')]
        [float] $Intensity,

        [Parameter(Mandatory, ParameterSetName = 'Standard')]
        [float] $Sharpness,

        [Parameter(Mandatory, ParameterSetName = 'Advanced')]
        [float] $Amplitude,

        [Parameter(Mandatory, ParameterSetName = 'Advanced')]
        [float] $Frequency
    )

    if ($DurationMilliseconds -le 0) {
        Write-Error "DurationMilliseconds must be greater than 0, but was $DurationMilliseconds" -ErrorAction Stop
    }
    switch ($PSCmdlet.ParameterSetName) {
        'Standart' {
            if ($Intensity -lt 0 -or 1 -lt $Intensity) {
                Write-Error "Intensity must be between 0 and 1, but was $Intensity" -ErrorAction Stop
            }
            if ($Sharpness -lt 0 -or 1 -lt $Sharpness) {
                Write-Error "Sharpness must be between 0 and 1, but was $Sharpness" -ErrorAction Stop
            }
        }
        'Advanced' {
            if ($Amplitude -lt 0 -or 1 -lt $Amplitude) {
                Write-Error "Amplitude must be between 0 and 1, but was $Amplitude" -ErrorAction Stop
            }
            if ($Frequency -le 0) {
                Write-Error "Frequency must be greater than 0, but was $Frequency" -ErrorAction Stop
            }
        }
    }

    $isAdvanced = $PSCmdlet.ParameterSetName -eq 'Advanced'

    $segment = [PSCustomObject]@{
        DurationMilliseconds = $DurationMilliseconds
        Intensity            = if (-not $isAdvanced) { $Intensity } else { $null }
        Sharpness            = if (-not $isAdvanced) { $Sharpness } else { $null }
        Amplitude            = if ($isAdvanced) { $Amplitude } else { $null }
        Frequency            = if ($isAdvanced) { $Frequency } else { $null }
        IsAdvanced           = $isAdvanced
    }

    $segment | Add-Member -MemberType ScriptMethod -Name 'ToAdbArguments' -Value {
        $p2 = if ($this.IsAdvanced) { $this.Amplitude } else { $this.Intensity }
        $p3 = if ($this.IsAdvanced) { $this.Frequency } else { $this.Sharpness }

        $p2Str = $p2.ToString('G', [System.Globalization.CultureInfo]::InvariantCulture)
        $p3Str = $p3.ToString('G', [System.Globalization.CultureInfo]::InvariantCulture)

        return " $($this.DurationMilliseconds) $p2Str $p3Str"
    }

    return $segment
}
