function Set-AdbFontScale {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [ValidateRange(0.25, 5)]
        [float] $FontScale
    )

    Set-AdbSetting -DeviceId $DeviceId -Namespace system -Name 'font_scale' -Value $FontScale -Verbose:$VerbosePreference
}
