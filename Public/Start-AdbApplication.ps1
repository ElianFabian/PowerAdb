# Starts an application or resumes it if it's already been open
function Start-AdbApplication {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $ApplicationId
    )

    process {
        foreach ($id in $DeviceId) {
            foreach ($appId in $ApplicationId) {
                $id | Invoke-AdbExpression -Command "shell monkey -p $appId -c android.intent.category.LAUNCHER 1" -Verbose:$VerbosePreference | Out-Null
            }
        }
    }
}
