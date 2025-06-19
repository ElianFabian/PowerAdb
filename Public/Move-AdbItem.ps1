function Move-AdbItem {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $LiteralRemotePath,

        [Parameter(Mandatory)]
        [string] $RemoteDestination
    )

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell ""mv '$LiteralRemotePath' '$RemoteDestination'""" -Verbose:$VerbosePreference
}
