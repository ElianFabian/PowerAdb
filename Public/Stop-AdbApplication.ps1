function Stop-AdbApplication {

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
                $result = Invoke-AdbExpression -DeviceId $id -Command "shell am force-stop ""$appId""" -Verbose:$VerbosePreference
                Write-Verbose "Force stop ""$appId"": $result"
            }
        }
    }
}
