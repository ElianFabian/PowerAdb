function Clear-AdbLogcat {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

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

        [string] $Pattern,

        [switch] $Force
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
        if ($bufferLowerCase) {
            $bufferArg = " --buffer=$bufferLowerCase"
        }
        if ($Pattern) {
            $regexArg = " --regex=$Pattern"
        }

        $adbArgs = @(
            $bufferArg,
            $regexArg
        ) -join ""
    }

    process {
        foreach ($id in $DeviceId) {
            do {
                $logcatError = Invoke-AdbExpression -DeviceId $id -Command "logcat -c$adbArgs" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false 2>&1
                if ((-not $Force -or $logcatError -notmatch "logcat: failed to clear the '\w+' log.") -and $logcatError -and $logcatError -is [System.Management.Automation.ErrorRecord]) {
                    Write-Error -Exception $logcatError.Exception
                }
            }
            while ($Force -and $logcatError -and $logcatError -is [System.Management.Automation.ErrorRecord] -and $logcatError.Exception.Message -match "logcat: failed to clear the '\w+' log.")
        }
    }
}
