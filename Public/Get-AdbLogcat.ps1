function Get-AdbLogcat {

    [CmdletBinding(DefaultParameterSetName = "Default")]
    param (
        [Parameter(Mandatory)]
        [string] $DeviceId,

        [ValidateSet(
            "Main",
            "System",
            "Radio",
            "Events",
            "Crash",
            "Kernel",
            "Security"
        )]
        [string] $Buffer,

        [switch] $LogsBeforeLastReboot,

        [switch] $ExitAfterDump,

        [string] $ParentProcessId,

        [ValidateSet(
            "Brief",
            "Long",
            "Process",
            "Raw",
            "Tag",
            "Thread",
            "ThreadTime",
            "Time"
        )]
        [string] $Format,

        [switch] $Dividers,

        [switch] $Binary,

        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Last")]
        [Parameter(ParameterSetName = "LastAt")]
        [Parameter(ParameterSetName = "IgnoreOld")]
        [Parameter(ParameterSetName = "Print")]
        [string] $Pattern,

        [Parameter(ParameterSetName = "Last")]
        [int] $Last,

        # Valid formats:
        # - MM-DD hh:mm:ss.mmm...
        # - YYYY-MM-DD hh:mm:ss.mmm...
        # - sssss.mmm...
        [Parameter(ParameterSetName = "Print")]
        [Parameter(ParameterSetName = "LastAt")]
        [ValidatePattern(
            "^\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+$|^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+$|^\d+\.\d+$"
        )]
        [string] $LastAt,

        [Parameter(ParameterSetName = "Print")]
        [Parameter(ParameterSetName = "IgnoreOld")]
        [switch] $IgnoreOld,

        [Parameter(ParameterSetName = "Print")]
        [Parameter(ParameterSetName = "Last")]
        [Parameter(ParameterSetName = "LastAt")]
        [switch] $Block,

        [Parameter(Mandatory, ParameterSetName = "Print")]
        [int] $StopAtMatchCount,

        # Valid formats:
        # - Tag:Priority
        # - Tag
        # - :Priority
        [string[]] $FilteredTag
    )

    begin {
        $bufferLowerCase = switch ($Buffer) {
            "Main" { "main" }
            "System" { "system" }
            "Radio" { "radio" }
            "Events" { "events" }
            "Crash" { "crash" }
            "Kernel" { "kernel" }
            "Security" { "security" }
            default { $null }
        }
        $formatLowerCase = switch ($Format) {
            "Brief" { "brief" }
            "Long" { "long" }
            "Process" { "process" }
            "Raw" { "raw" }
            "Tag" { "tag" }
            "Thread" { "thread" }
            "ThreadTime" { "threadtime" }
            "Time" { "time" }
            default { $null }
        }

        if ($bufferLowerCase) {
            $bufferArg = " --buffer=$bufferLowerCase"
        }
        if ($LogsBeforeLastReboot) {
            $lastArg = " --last"
        }
        if ($ExitAfterDump) {
            $dArg = " -d"
        }
        if ($ParentProcessId) {
            $pidArg = " --pid=$ParentProcessId"
        }
        if ($Format) {
            $formatArg = " --format=$formatLowerCase"
        }
        if ($Dividers) {
            $dividersArg = " --dividers"
        }
        if ($Binary) {
            $binaryArg = " --binary"
        }
        if ($Pattern) {
            $regexArg = " --regex='$Pattern'"
        }
        if ($PSCmdlet.ParameterSetName -eq "Print") {
            $maxCountArg = " --max-count=$StopAtMatchCount"
            $printArg = " --print"
        }

        if ($Block) {
            if ($Last) {
                $countOrTimeFilterArg = " -T $Last"
            }
            elseif ($LastAt) {
                $countOrTimeFilterArg = " -T '$LastAt'"
            }
        }
        else {
            if ($Last) {
                $countOrTimeFilterArg = " -t $Last"
            }
            elseif ($LastAt) {
                $countOrTimeFilterArg = " -t '$LastAt'"
            }
        }

        if ($IgnoreOld) {
            $currentDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
            $countOrTimeFilterArg = " -T '$currentDate'"
        }

        if ($FilteredTag) {
            $filterspec = " $($FilteredTag -join ' ') *:S"
        }

        $adbArgs = @(
            $bufferArg,
            $lastArg,
            $dArg,
            $pidArg,
            $formatArg,
            $dividersArg,
            $binaryArg,
            $regexArg,
            $printArg,
            $maxCountArg,
            $countOrTimeFilterArg,
            $filterspec
        ) -join ""
    }

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $DeviceId -Command "logcat$adbArgs" -Verbose:$VerbosePreference
        }
    }
}
