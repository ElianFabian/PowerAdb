function Move-AdbItem {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $LiteralRemotePath,

        [Parameter(Mandatory)]
        [string] $RemoteDestination
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell ""mv '$LiteralRemotePath' '$RemoteDestination'""" -Verbose:$VerbosePreference
        }
    }
}
