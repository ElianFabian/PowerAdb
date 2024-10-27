function Start-AdbAppCrash {

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
                $id | Invoke-AdbExpression -Command "shell am crash '$appId'" -Verbose:$VerbosePreference
            }
        }
    }
}
