function New-AdbOneShotVibration {

    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory)]
        [byte] $Amplitude,

        [Parameter(Mandatory)]
        [uint32] $DurationMilliseconds,

        [uint32] $DelayMilliseconds = 0
    )

    if ($DelayMilliseconds -gt 0) {
        Assert-ApiLevel -SerialNumber $SerialNumber -From 31 -To 35 -FeatureName "$($MyInvocation.MyCommand.Name) -DelayMilliseconds"
    }

    $output = [PSCustomObject]@{
        DurationMilliseconds = $DurationMilliseconds
        Amplitude            = $Amplitude
        DelayMilliseconds    = $DelayMilliseconds
    }

    $output | Add-Member -MemberType ScriptMethod -Name 'ToAdbArguments' -Value {
        if ($this.DelayMilliseconds -gt 0) {
            $delayArg = " -w $($this.DelayMilliseconds)"
        }
        return " oneshot$delayArg -a $($this.DurationMilliseconds) $($this.Amplitude)"
    }

    return $output
}
