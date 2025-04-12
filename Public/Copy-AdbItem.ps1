function Copy-AdbItem {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $RemotePath,

        [Parameter(Mandatory)]
        [string] $RemoteDestination
    )

    $sanitizedRemotePath = ConvertTo-ValidAdbStringArgument $RemotePath
    $sanitizedRemoteDestination = ConvertTo-ValidAdbStringArgument $RemoteDestination

    Invoke-AdbExpression -DeviceId $DeviceId -Command "shell cp $sanitizedRemotePath $sanitizedRemoteDestination" -Verbose:$VerbosePreference
}
