# Frees up app memory if possible
function Start-AdbPackageProcessDeath {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName,

        [Parameter(ParameterSetName = 'Force')]
        [switch] $Force,

        [Parameter(ParameterSetName = 'ForceAndReturnToApp')]
        [switch] $ForceAndReturnToApp
    )

    process {
        foreach ($id in $DeviceId) {
            foreach ($package in $PackageName) {
                if ($Force -or $ForceAndReturnToApp) {
                    $topActivity = Get-AdbTopActivity -DeviceId $id -Verbose:$false
                    if ($topActivity.PackageName -eq $package) {
                        Send-AdbKeyEvent -DeviceId $id -KeyCode HOME -Verbose:$VerbosePreference
                    }
                }
                Invoke-AdbExpression -DeviceId $id -Command "shell am kill '$package'" -Verbose:$VerbosePreference

                if ($ForceAndReturnToApp) {
                    Start-AdbPackage -DeviceId $id -PackageName $package -Verbose:$VerbosePreference
                }
            }
        }
    }
}
