function Get-AdbEmulatorName {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    Invoke-EmuExpression -SerialNumber $SerialNumber -Command 'avd name' -Verbose:$VerbosePreference
}
