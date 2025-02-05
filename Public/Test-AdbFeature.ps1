function Test-AdbFeature {

    [CmdletBinding()]
    [OutputType([bool[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $Feature,

        # Fast for multiple features
        [switch] $Fast
    )

    process {
        foreach ($id in $DeviceId) {
            if ($Fast) {
                $supportedFeatures = Get-AdbFeature -DeviceId $id -Verbose:$VerbosePreference
                foreach ($featureName in $Feature) {
                    if ($featureName.Contains(' ')) {
                        Write-Error "Feature '$featureName' can't contain any space"
                        continue
                    }

                    $featureName -in $supportedFeatures
                }
            }
            else {
                foreach ($featureName in $Feature) {
                    if ($featureName.Contains(' ')) {
                        Write-Error "Feature '$featureName' can't contain any space"
                        continue
                    }

                    $result = Invoke-AdbExpression -DeviceId $id -Command "shell pm has-feature $featureName" -Verbose:$VerbosePreference

                    [bool]::Parse($result)
                }
            }
        }
    }
}
