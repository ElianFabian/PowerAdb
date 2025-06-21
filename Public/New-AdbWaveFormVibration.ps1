function New-AdbWaveFormVibration {

    param (
        [int] $RepeatAtIndex = -1,

        [switch] $Continuous,

        [uint32] $DelayMilliseconds = 0,

        [Parameter(Mandatory = $false, Position = 0)]
        [scriptblock] $Vibration
    )

    if (-not $Vibration -and $args.Count -gt 0 -and $args[0] -is [ScriptBlock]) {
        $Vibration = $args[0]
    }

    $output = [PSCustomObject]@{
        RepeatAtIndex     = $RepeatAtIndex
        Continuous        = $Continuous
        DelayMilliseconds = $DelayMilliseconds
        Vibration         = $Vibration
    }

    $output | Add-Member -MemberType ScriptMethod -Name 'ToAdbArguments' -Value {
        $vibrationsString = ($this.Vibration.Invoke() | ForEach-Object { $_.ToAdbArguments() }) -join ''
        if ($this.Continuous) {
            $continuousArg = ' -c'
        }
        return " waveform -w $($this.DelayMilliseconds) -r $($this.RepeatAtIndex) -a -f$continuousArg$vibrationsString"
    }

    return $output
}
