function Test-AdbFeature {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $Permission
    )

    process {
        foreach ($id in $DeviceId) {
            # Faster than 'adb shell pm has-feature'
            $supportedFeatures = Get-AdbFeature -DeviceId $id
            foreach ($permissionName in $Permission) {
                if ($permissionName.Contains(' ')) {
                    Write-Error "Permission '$permissionName' can't contain any space"
                    continue
                }

                $permissionName -in $supportedFeatures
            }
        }
    }
}
