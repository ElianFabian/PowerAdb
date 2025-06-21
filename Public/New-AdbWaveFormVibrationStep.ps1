function New-AdbWaveFormVibrationStep {

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int] $DurationMilliseconds,

        [byte] $Amplitude = 0,

        # Frequency doesn't seem to do anything, even in the source code of VibrationEffect it seems to always be zero.
        [int] $Frequency = 1
    )

    if ($Frequency -lt 1) {
        Write-Error "Frequency must be greater than or equal to 1, but was $Frequency" -ErrorAction Stop
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
