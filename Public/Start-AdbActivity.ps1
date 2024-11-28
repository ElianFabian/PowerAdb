function Start-AdbActivity {

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [switch] $EnableDebugging,

        [switch] $EnableNativeDebugging,

        [switch] $WaitForLaunch,

        [Parameter(ParameterSetName = 'Profiler')]
        [switch] $StartProfiler,

        [Parameter(ParameterSetName = 'Profiler')]
        [switch] $StopWhenIdle,

        [Parameter(ParameterSetName = 'Profiler')]
        [string] $LiteralRemoteProfilerPath,

        [Parameter(ParameterSetName = 'Profiler')]
        [uint64] $SamplingIntervalInMicroseconds,

        [Parameter(ParameterSetName = 'Profiler')]
        [switch] $Streaming,

        [uint32] $RepeatCount = 0,

        [switch] $ForceStopBeforeStartingActivity,

        [switch] $TrackAllocation,

        [ValidateSet(
            'Undefined',
            'Fullscreen',
            'Pinned',
            'Freeform',
            'MultiWindow'
        )]
        [string] $WindowingMode,

        [ValidateSet(
            'Undefined',
            'Standard',
            'Home',
            'Recents',
            'Assistant',
            'Dream'
        )]
        [string] $ActivityType,

        [Parameter(Mandatory)]
        [PSCustomObject] $Intent
    )

    begin {
        $windowingModeCode = switch ($WindowingMode) {
            'Fullscreen' { 1 }
            'Pinned' { 2 }
            'Freeform' { 5 }
            'MultiWindow' { 6 }
            default { 0 }
        }
        $activityTypeCode = switch ($ActivityType) {
            'Standard' { 1 }
            'Home' { 2 }
            'Recents' { 3 }
            'Assistant' { 4 }
            'Dream' { 5 }
            default { 0 }
        }
        $intentArgs = $Intent.ToAdbArguments()

        $argumentsSb = [System.Text.StringBuilder]::new()

        if ($EnableDebugging) {
            $argumentsSb.Append(' -D') > $null
        }
        if ($EnableNativeDebugging) {
            $argumentsSb.Append(' -N') > $null
        }
        if ($WaitForLaunch) {
            $argumentsSb.Append(' -W') > $null
        }
        if ($StartProfiler -and $StopWhenIdle) {
            $argumentsSb.Append(" -P $LiteralRemoteProfilerPath") > $null
        }
        elseif ($StartProfiler) {
            $argumentsSb.Append(" --start-profiler $LiteralRemoteProfilerPath") > $null
        }
        if ($SamplingIntervalInMicroseconds -gt 0) {
            $argumentsSb.Append(" --sampling $SamplingIntervalInMicroseconds") > $null
        }
        if ($Streaming) {
            $argumentsSb.Append(' --streaming') > $null
        }
        if ($RepeatCount -gt 0) {
            $argumentsSb.Append(" -R $RepeatCount") > $null
        }
        if ($ForceStopBeforeStartingActivity) {
            $argumentsSb.Append(' -S') > $null
        }
        if ($TrackAllocation) {
            $argumentsSb.Append(' --track-allocation') > $null
        }
        if ($windowingModeCode -ne 0) {
            $argumentsSb.Append(" --windowingMode $windowingModeCode") > $null
        }
        if ($activityTypeCode -ne 0) {
            $argumentsSb.Append(" --activityType $activityTypeCode") > $null
        }
        $argumentsSb.Append(" $intentArgs") > $null
    }

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell am start $($argumentsSb.ToString().Trim())" -Verbose:$VerbosePreference
        }
    }
}

# TODO: add support for the following parameters:
# --attach-agent
# --attach-agent-bind
# --user
# --display
