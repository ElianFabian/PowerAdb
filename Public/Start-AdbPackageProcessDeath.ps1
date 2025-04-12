# Frees up app memory if possible
function Start-AdbPackageProcessDeath {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName,

        [switch] $Force
    )

    foreach ($package in $PackageName) {
        if ($Force) {
            $topActivity = Get-AdbTopActivity -DeviceId $DeviceId -Verbose:$false
            if ($topActivity.PackageName -eq $package) {
                Send-AdbKeyEvent -DeviceId $DeviceId -KeyCode HOME -Verbose:$VerbosePreference
            }
        }
        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell am kill '$package'" -Verbose:$VerbosePreference
    }
}
