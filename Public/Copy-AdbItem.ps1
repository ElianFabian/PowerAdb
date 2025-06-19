function Copy-AdbItem {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $RemotePath,

        [Parameter(Mandatory)]
        [string] $RemoteDestination
    )

    $sanitizedRemotePath = ConvertTo-ValidAdbStringArgument $RemotePath
    $sanitizedRemoteDestination = ConvertTo-ValidAdbStringArgument $RemoteDestination

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell cp $sanitizedRemotePath $sanitizedRemoteDestination" -Verbose:$VerbosePreference
}
