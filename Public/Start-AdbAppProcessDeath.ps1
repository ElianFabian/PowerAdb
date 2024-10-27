# Frees up app memory if possible
function Start-AdbAppProcessDeath {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string[]] $ApplicationId
    )

    process {
        foreach ($id in $DeviceId) {
            foreach ($appId in $ApplicationId) {
                Invoke-AdbExpression -DeviceId $id -Command "shell am kill '$appId'" -Verbose:$VerbosePreference
            }
        }
    }
}
