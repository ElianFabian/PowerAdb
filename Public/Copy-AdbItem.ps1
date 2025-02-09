function Copy-AdbItem {
   
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $RemotePath,

        [Parameter(Mandatory)]
        [string] $RemoteDestination
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell ""cp '$RemotePath' '$RemoteDestination'""" -Verbose:$VerbosePreference
        }
    }
}
