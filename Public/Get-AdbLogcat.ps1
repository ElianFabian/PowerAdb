function Get-AdbLogcat {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [string] $SerialNumber,

        [ValidateSet(
            'main',
            'system',
            'radio',
            'events',
            'all',
            'crash',
            'kernel',
            'security'
        )]
        [string[]] $Buffer,

        [switch] $LogsBeforeLastReboot,

        [switch] $ExitAfterDump,

        [string] $ParentProcessId,

        [ValidateSet(
            'brief',
            'process',
            'tag',
            'thread',
            'raw',
            'time',
            'threadTime',
            'long'
        )]
        [string] $FormatVerb = 'threadtime',

        # TODO: Maybe add support for "<zone>"
        [ValidateSet(
            'color',
            'epoch',
            'monotonic',
            'printable',
            'uid',
            'usec',
            'UTC',
            'year',
            'zone',
            'descriptive'
        )]
        [string[]] $FormatAdverd,

        [switch] $Dividers,

        [switch] $Binary,

        [switch] $Proto,

        # TODO: Maybe add support for Logd control

        [string] $Pattern,

        [Parameter(ParameterSetName = 'Last')]
        [int] $Last,

        # Valid formats:
        # - MM-DD hh:mm:ss.mmm...
        # - YYYY-MM-DD hh:mm:ss.mmm...
        # - sssss.mmm...
        [Parameter(ParameterSetName = 'Print')]
        [Parameter(ParameterSetName = 'LastAt')]
        # [ValidatePattern(
        #     '^\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+$|^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+$|^\d+\.\d+$'
        # )]
        [string] $LastAt,

        [Parameter(ParameterSetName = 'Print')]
        [Parameter(ParameterSetName = 'IgnoreOld')]
        [switch] $IgnoreOld,

        [Parameter(ParameterSetName = 'Print')]
        [Parameter(ParameterSetName = 'Last')]
        [Parameter(ParameterSetName = 'LastAt')]
        [switch] $Block,

        [Parameter(Mandatory, ParameterSetName = 'Print')]
        [int] $StopAtMatchCount,

        # Valid formats:
        # - Tag:Priority
        # - Tag
        # - :Priority
        [string[]] $FilteredTag
    )

    if ('crash' -in $Buffer) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 21 -FeatureName "$($MyInvocation.MyCommand.Name) -Buffer crash"
    }
    if ($Last) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 21 -FeatureName "$($MyInvocation.MyCommand.Name) -Last"
    }
    if ($LastAt) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 21 -FeatureName "$($MyInvocation.MyCommand.Name) -LastAt"
    }
    if ($IgnoreOld) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 21 -FeatureName "$($MyInvocation.MyCommand.Name) -IgnoreOld"
    }
    if ($StopAtMatchCount) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 21 -FeatureName "$($MyInvocation.MyCommand.Name) -StopAtMatchCount"
    }
    if ($FormatAdverd) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 23 -FeatureName "$($MyInvocation.MyCommand.Name) -FormatAdverd"
    }
    if ($Dividers) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 23 -FeatureName "$($MyInvocation.MyCommand.Name) -Dividers"
    }
    if ($Pattern) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 23 -FeatureName "$($MyInvocation.MyCommand.Name) -Pattern"
    }
    if ($LogsBeforeLastReboot) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 23 -FeatureName "$($MyInvocation.MyCommand.Name) -LogsBeforeLastReboot"
    }
    if ($ParentProcessId) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 23 -FeatureName "$($MyInvocation.MyCommand.Name) -ParentProcessId"
    }
    if ('descriptive' -in $FormatVerb) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 26 -FeatureName "$($MyInvocation.MyCommand.Name) -FormatAdverd 'descriptive'"
    }
    if ('kernel' -in $Buffer) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 29 -FeatureName "$($MyInvocation.MyCommand.Name) -Buffer kernel"
    }
    if ('security' -in $Buffer) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 29 -FeatureName "$($MyInvocation.MyCommand.Name) -Buffer security"
    }
    if ($Proto) {
        Assert-ApiLevel -SerialNumber $SerialNumber -GreaterThanOrEqualTo 35 -FeatureName "$($MyInvocation.MyCommand.Name) -Proto"
    }

    if ('all' -in $Buffer) {
        $apiLevel = Get-AdbApiLevel -SerialNumber $SerialNumber -Verbose:$false

        $bufferInternal = @('main', 'system', 'radio', 'events')

        if ($apiLevel -ge 21) {
            $bufferInternal += 'crash'
        }
        if ($apiLevel -ge 29) {
            $bufferInternal += @('kernel', 'security')
        }
    }
    else {
        $bufferInternal = $Buffer
    }

    $bufferInternal = $bufferInternal | Select-Object -Unique

    $adbArgSb = [System.Text.StringBuilder]::new()

    if ($bufferInternal) {
        $adbArgSb.Append(" $(($bufferInternal | ForEach-Object { "-b $_" }) -join ' ')") > $null
    }
    if ($ExitAfterDump) {
        $adbArgSb.Append(" -d") > $null
    }
    if ($LogsBeforeLastReboot) {
        $adbArgSb.Append(" --last") > $null
    }
    if ($ParentProcessId) {
        $adbArgSb.Append(" --pid=$ParentProcessId") > $null
    }
    if ($FormatVerb -or $FormatAdverd) {
        $formatArg = ($FormatVerb + $FormatAdverd) -join ','
        $adbArgSb.Append(" -v $formatArg") > $null
    }
    if ($Dividers) {
        $adbArgSb.Append(" --dividers") > $null
    }
    if ($Binary) {
        $adbArgSb.Append(" -B") > $null
    }
    if ($Proto) {
        $adbArgSb.Append(" --proto") > $null
    }
    if ($Pattern) {
        # Sanitizing doesn't work for the pattern argument, so we need to escape single quotes manually.
        $sanitizedPattern = $Pattern.Replace("'", "''")
        $adbArgSb.Append(" -e '$sanitizedPattern'") > $null
    }
    if ($PSCmdlet.ParameterSetName -eq "Print") {
        $adbArgSb.Append(" --print") > $null
        $adbArgSb.Append(" --max-count=$StopAtMatchCount") > $null
    }
    if ($Block) {
        if ($Last) {
            $adbArgSb.Append(" -T $Last") > $null
        }
        elseif ($LastAt) {
            $adbArgSb.Append(" -T '$LastAt'") > $null
        }
    }
    else {
        if ($Last) {
            $adbArgSb.Append(" -t $Last") > $null
        }
        elseif ($LastAt) {
            $adbArgSb.Append(" -t '$LastAt'") > $null
        }
    }
    if ($IgnoreOld) {
        $currentDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'
        $adbArgSb.Append(" -T '$currentDate'") > $null
    }
    if ($FilteredTag) {
        $adbArgSb.Append(" $($FilteredTag -join ' ') *:S") > $null
    }

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "logcat$adbArgSb" -Verbose:$VerbosePreference
}
