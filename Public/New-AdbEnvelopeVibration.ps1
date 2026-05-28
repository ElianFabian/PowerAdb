function New-AdbEnvelopeVibration {

    # In a Pixel 8 Pro API 36 device this command does nothing

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param (
        [switch] $Advanced,

        [float] $InitialSharpness = -1,

        [int] $RepeatAtIndex = -1,

        [Parameter(Mandatory, Position = 0)]
        [scriptblock] $Vibration
    )

    if (-not $Vibration -and $args.Count -gt 0 -and $args[0] -is [ScriptBlock]) {
        $Vibration = $args[0]
    }

    $output = [PSCustomObject]@{
        Advanced         = $Advanced
        InitialSharpness = $InitialSharpness
        RepeatAtIndex    = $RepeatAtIndex
        Vibration        = $Vibration
    }

    $output | Add-Member -MemberType ScriptMethod -Name 'ToAdbArguments' -Value {
        $steps = @($this.Vibration.Invoke())

        foreach ($step in $steps) {
            if ($null -ne $step.IsAdvanced -and $step.IsAdvanced -ne $this.Advanced) {
                $expected = if ($this.Advanced) { "Advanced (-Amplitude, -Frequency)" } else { "Standard (-Intensity, -Sharpness)" }
                $actual = if ($step.IsAdvanced) { "Advanced" } else { "Standard" }
                Write-Error "Consistency Error: The envelope container is configured as $expected, but an internal step is using $actual parameters." -ErrorAction Stop
            }
        }

        # FIX: Basic envelope effects must end at a zero intensity control point.
        if (-not $this.Advanced -and $steps.Count -gt 0) {
            $lastStep = $steps[-1]
            if ($lastStep.Intensity -ne 0.0) {
                $decayStep = New-AdbEnvelopeVibrationStep -DurationMilliseconds 1 -Intensity 0.0 -Sharpness $lastStep.Sharpness
                $steps += $decayStep
            }
        }

        $stepsString = ($steps | ForEach-Object { $_.ToAdbArguments() }) -join ''

        $advancedArg = if ($this.Advanced) { ' -a' } else { '' }
        $initialSharpnessArg = if ($this.InitialSharpness -ge 0) { " -i $($this.InitialSharpness)" } else { '' }
        $repeatArg = if ($this.RepeatAtIndex -ge 0) { " -r $($this.RepeatAtIndex)" } else { '' }

        return " envelope$advancedArg$initialSharpnessArg$repeatArg$stepsString"
    }

    return $output
}
