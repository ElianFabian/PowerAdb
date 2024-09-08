function Set-AdbFontScale {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [ValidateRange(0.25, 5)]
        [float] $FontScale
    )

    process {
        foreach ($id in $DeviceId) {
            $id | Invoke-AdbExpression -Command "shell settings put system font_scale $FontScale" -Verbose:$VerbosePreference | Out-Null
        }
    }
}
