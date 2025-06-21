function Suspend-AdbEmulator {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber
    )

    # NOTES: It seems that 'pause' and 'stop' work the same, I don't know why.
    Invoke-EmuExpression -SerialNumber $SerialNumber -Command 'avd pause' -Verbose:$VerbosePreference
}
