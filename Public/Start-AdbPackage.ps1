# Starts an application or resumes it if it's already been open
function Start-AdbPackage {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    foreach ($package in $PackageName) {
        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell monkey -p '$package' -c android.intent.category.LAUNCHER 1" -Verbose:$VerbosePreference > $null
    }
}
