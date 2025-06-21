function New-AdbOneShotVibration {

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [uint32] $DurationMilliseconds,

        [byte] $Amplitude = 0,

        [uint32] $DelayMilliseconds = 0
    )

    $output = [PSCustomObject]@{
        DurationMilliseconds = $DurationMilliseconds
        Amplitude            = $Amplitude
        DelayMilliseconds    = $DelayMilliseconds
    }

    $output | Add-Member -MemberType ScriptMethod -Name 'ToAdbArguments' -Value {
        return " oneshot -w $($this.DelayMilliseconds) -a $($this.DurationMilliseconds) $($this.Amplitude)"
    }

    return $output
}
