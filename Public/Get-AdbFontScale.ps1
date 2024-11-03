function Get-AdbFontScale {

    [OutputType([float[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $result = ($id | Invoke-AdbExpression -Command "shell settings get system font_scale" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false) -as [float]
            if ($result) {
                return $result
            }
            else {
                # When it's null it means it's the default value, 1
                return 1.0
            }
        }
    }
}
