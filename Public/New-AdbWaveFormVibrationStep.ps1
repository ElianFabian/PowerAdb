function New-AdbWaveFormVibrationStep {

    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory)]
        [int] $DurationMilliseconds,

        [byte] $Amplitude = 0,

        # Frequency doesn't seem to do anything, even in the source code of VibrationEffect it seems to always be zero.
        [int] $Frequency = 1
    )

    if ($Frequency -le 0) {
        Write-Error "Frequency must be greater than 01, but was $Frequency" -ErrorAction Stop
    }

    $segment = [PSCustomObject]@{
        DurationMilliseconds = $DurationMilliseconds
        Amplitude            = $Amplitude
        Frequency            = $Frequency
    }

    $segment | Add-Member -MemberType ScriptMethod -Name 'ToAdbArguments' -Value {
        return " $($this.DurationMilliseconds) $($this.Amplitude) $($this.Frequency)"
    }

    return $segment
}
