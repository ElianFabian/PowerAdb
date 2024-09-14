function Clear-AdbApplication {

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
                $result = Invoke-AdbExpression -DeviceId $id -Command "shell pm clear $appId" -Verbose:$VerbosePreference
                Write-Verbose "Clear data in device with id '$id' from '$appId': $result"
            }
        }
    }
}
