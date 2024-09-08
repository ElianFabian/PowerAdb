function Get-AdbApplicationPid {

    [OutputType([uint[]])]
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
                [uint] (Invoke-AdbExpression -DeviceId $id -Command "shell pidof $appId" -Verbose:$VerbosePreference)
            }
        }
    }
}
