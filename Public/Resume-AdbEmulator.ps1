function Resume-AdbEmulator {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber
    )

    # NOTES: It seems that 'resume' and 'start' work the same, I don't know why.
    Invoke-EmuExpression -SerialNumber $SerialNumber -Command 'avd resume' -Verbose:$VerbosePreference
}
