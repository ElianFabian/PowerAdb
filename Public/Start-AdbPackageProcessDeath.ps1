# Frees up app memory if possible
function Start-AdbPackageProcessDeath {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName,

        [switch] $Force
    )

    process {
        foreach ($id in $DeviceId) {
            foreach ($package in $PackageName) {
                if ($Force) {
                    $topActivity = Get-AdbTopActivity -DeviceId $id -Verbose:$false
                    if ($topActivity.PackageName -eq $package) {
                        Send-AdbKeyEvent -DeviceId $id -KeyCode HOME -Verbose:$VerbosePreference
                    }
                }
                Invoke-AdbExpression -DeviceId $id -Command "shell am kill '$package'" -Verbose:$VerbosePreference
            }
        }
    }
}
