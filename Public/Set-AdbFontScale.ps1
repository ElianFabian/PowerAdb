function Set-AdbFontScale {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [ValidateRange(0.25, 5)]
        [float] $FontScale
    )

    Set-AdbSetting -SerialNumber $SerialNumber -Namespace system -Name 'font_scale' -Value $FontScale -Verbose:$VerbosePreference
}
