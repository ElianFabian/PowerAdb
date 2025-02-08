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

        [string] $Pattern
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
            Invoke-AdbExpression -DeviceId $id -Command "logcat --clear$adbArgs"
        }
    }
}
