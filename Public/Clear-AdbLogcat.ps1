function Clear-AdbLogcat {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [ValidateSet(
            "main",
            "system",
            "radio",
            "events",
            "crash",
            "kernel",
            "security"
        )]
        [string[]] $Buffer,

        [string] $Pattern,

        [switch] $Force
    )

    if ('crash' -in $Buffer) {
        Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 21 -FeatureName "$($MyInvocation.MyCommand.Name) -Buffer 'Crash'"
    }
    if ($Pattern) {
        Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 23 -FeatureName "$($MyInvocation.MyCommand.Name) -Pattern"
    }
    if ('kernel' -in $Buffer) {
        Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 29 -FeatureName "$($MyInvocation.MyCommand.Name) -Buffer 'Kernel'"
    }
    if ('security' -in $Buffer) {
        Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 29 -FeatureName "$($MyInvocation.MyCommand.Name) -Buffer 'Security'"
    }

    if ('all' -in $Buffer) {
        $apiLevel = Get-AdbApiLevel -DeviceId $DeviceId -Verbose:$false

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

    if ($bufferInternal) {
        $bufferArg = " $(($bufferInternal | ForEach-Object { "-b $_" }) -join ' ')"
    }
    if ($Pattern) {
        $regexArg = " --regex=$(ConvertTo-ValidAdbStringArgument $Pattern)"
    }

    $adbArgs = @(
        $bufferArg
        $regexArg
    ) -join ""

    do {
        try {
            Invoke-AdbExpression -DeviceId $DeviceId -Command "logcat -c$adbArgs" -Verbose:$VerbosePreference
        }
        catch {
            if ($_.ErrorDetails -isnot [AdbCommandException] -and "logcat: failed to clear the '\w+' log." -notmatch $_.Exception.Message) {
                throw $_
            }
            $logcatClearError = $_
        }
    }
    while ($Force -and $logcatClearError)
}
