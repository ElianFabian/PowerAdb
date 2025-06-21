function Get-AdbEmulatorPath {

    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    Invoke-EmuExpression -SerialNumber $SerialNumber -Command 'avd path' -Verbose:$VerbosePreference
}
