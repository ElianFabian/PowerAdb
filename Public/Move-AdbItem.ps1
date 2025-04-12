function Move-AdbItem {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $LiteralRemotePath,

        [Parameter(Mandatory)]
        [string] $RemoteDestination
    )

    Invoke-AdbExpression -DeviceId $DeviceId -Command "shell ""mv '$LiteralRemotePath' '$RemoteDestination'""" -Verbose:$VerbosePreference
}
