# Starts an application or resumes it if it's already been open
function Start-AdbPackage {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $PackageName
    )

    process {
        foreach ($id in $DeviceId) {
            foreach ($package in $PackageName) {
                $id | Invoke-AdbExpression -Command "shell monkey -p '$package' -c android.intent.category.LAUNCHER 1" -Verbose:$VerbosePreference | Out-Null
            }
        }
    }
}
