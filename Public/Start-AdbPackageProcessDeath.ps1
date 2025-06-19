# Frees up app memory if possible
function Start-AdbPackageProcessDeath {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string[]] $PackageName,

        [switch] $Force
    )

    foreach ($package in $PackageName) {
        if ($Force) {
            $topActivity = Get-AdbTopActivity -SerialNumber $SerialNumber -Verbose:$false
            if ($topActivity.PackageName -eq $package) {
                Send-AdbKeyEvent -SerialNumber $SerialNumber -KeyCode HOME -Verbose:$VerbosePreference
            }
        }
        Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell am kill '$package'" -Verbose:$VerbosePreference
    }
}
