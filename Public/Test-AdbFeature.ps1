function Test-AdbFeature {

    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string[]] $Feature,

        # Fast for multiple features
        [switch] $Fast
    )

    $apiLevel = Get-AdbApiLevel -SerialNumber $SerialNumber -Verbose:$false
    if ($Fast -or $apiLevel -lt 26) {
        $supportedFeatures = Get-AdbFeature -SerialNumber $SerialNumber -Verbose:$VerbosePreference
    }

    foreach ($featureName in $Feature) {
        if ($featureName.Contains(' ')) {
            Write-Error "Feature '$featureName' can't contain any space"
            continue
        }

        if ($Fast -or $apiLevel -lt 26) {
            $featureName -in $supportedFeatures
        }
        else {
            $sanitizedFeatureName = ConvertTo-ValidAdbStringArgument $featureName
            $result = Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell pm has-feature $sanitizedFeatureName" -Verbose:$VerbosePreference

            [bool]::Parse($result)
        }
    }
}
