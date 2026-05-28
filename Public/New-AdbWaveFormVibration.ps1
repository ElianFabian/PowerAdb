function New-AdbWaveFormVibration {

    [OutputType([PSCustomObject])]
    param (
        [int] $RepeatAtIndex = -1,

        [switch] $Continuous,

        [uint32] $DelayMilliseconds = 0,

        [Parameter(Mandatory = $false, Position = 0)]
        [scriptblock] $Vibration
    )

    if ($DelayMilliseconds -gt 0) {
        Assert-ApiLevel -SerialNumber $SerialNumber -From 31 -To 35 -FeatureName "$($MyInvocation.MyCommand.Name) -DelayMilliseconds"
    }

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
        if ($this.DelayMilliseconds) {
            $delayArg = " -w $($this.DelayMilliseconds)"
        }
        return " waveform$delayArg -r $($this.RepeatAtIndex) -a -f$continuousArg$vibrationsString"
    }

    return $output
}
