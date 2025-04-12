function Test-AdbFeature {

    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $Feature,

        # Fast for multiple features
        [switch] $Fast
    )

    $apiLevel = Get-AdbApiLevel -DeviceId $DeviceId -Verbose:$false
    if ($Fast -or $apiLevel -lt 26) {
        $supportedFeatures = Get-AdbFeature -DeviceId $DeviceId -Verbose:$VerbosePreference
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
            $result = Invoke-AdbExpression -DeviceId $DeviceId -Command "shell pm has-feature '$featureName'" -Verbose:$VerbosePreference

            [bool]::Parse($result)
        }
    }
}
