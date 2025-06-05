function Start-AdbActivity {

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UserId')]
    param (
        [string] $DeviceId,

        [switch] $EnableDebugging,

        [switch] $EnableNativeDebugging,

        [switch] $WaitForLaunch,

        [Parameter(Mandatory, ParameterSetName = 'Profiler')]
        [switch] $StartProfiler,

        [Parameter(ParameterSetName = 'Profiler')]
        [switch] $StopWhenIdle,

        [Parameter(Mandatory, ParameterSetName = 'Profiler')]
        [string] $LiteralRemoteProfilerPath,

        [Parameter(ParameterSetName = 'Profiler')]
        [uint64] $SamplingIntervalInMicroseconds,

        [Parameter(ParameterSetName = 'Profiler')]
        [switch] $Streaming,

        [uint32] $RepeatCount = 0,

        [switch] $ForceStopBeforeStartingActivity,

        [switch] $TrackAllocation,

        [AllowNull()]
        [object] $UserId,

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

    Assert-ValidIntent -DeviceId $DeviceId -Intent $Intent

    if ($StartProfiler) {
        Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 17 -FeatureName "$($MyInvocation.MyCommand.Name) -StartProfiler"
    }
    if ($SamplingIntervalInMicroseconds) {
        Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 21 -FeatureName "$($MyInvocation.MyCommand.Name) -SamplingIntervalInMicroseconds"
    }
    if ($TrackAllocation) {
        Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 24 -FeatureName "$($MyInvocation.MyCommand.Name) -TrackAllocation"
    }
    if ($Streaming) {
        Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 26 -FeatureName "$($MyInvocation.MyCommand.Name) -Streaming"
    }
    if ($WindowingMode) {
        Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 28 -FeatureName "$($MyInvocation.MyCommand.Name) -WindowingMode"
    }
    if ($ActivityType) {
        Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 28 -FeatureName "$($MyInvocation.MyCommand.Name) -ActivityType"
    }

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
    $intentArgs = $Intent.ToAdbArguments($DeviceId)

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
        $argumentsSb.Append(" -P '$LiteralRemoteProfilerPath'") > $null
    }
    elseif ($StartProfiler) {
        $argumentsSb.Append(" --start-profiler '$LiteralRemoteProfilerPath'") > $null
    }
    if ($SamplingIntervalInMicroseconds -gt 0) {
        $argumentsSb.Append(" --sampling $SamplingIntervalInMicroseconds") > $null
    }
    if ($TrackAllocation) {
        $argumentsSb.Append(' --track-allocation') > $null
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
    $user = Resolve-AdbUser -DeviceId $DeviceId -UserId $UserId
    if ($null -ne $user) {
        $argumentsSb.Append(" --user $user") > $null
    }
    if ($windowingModeCode -ne 0) {
        $argumentsSb.Append(" --windowingMode $windowingModeCode") > $null
    }
    if ($activityTypeCode -ne 0) {
        $argumentsSb.Append(" --activityType $activityTypeCode") > $null
    }
    $argumentsSb.Append($intentArgs) > $null

    try {
        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell am start$($argumentsSb.ToString())" -Verbose:$VerbosePreference
    }
    catch {
        if ($_.Exception.Message.StartsWith('Warning:')) {
            return
        }
        throw $_
    }
}
