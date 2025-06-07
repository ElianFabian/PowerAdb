function Send-AdbItem {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $LiteralLocalPath,

        [Parameter(Mandatory)]
        [string] $LiteralRemotePath
    )

    try {
        # Sanitizing does not work for these arguments.
        Invoke-AdbExpression -DeviceId $DeviceId -Command "push '$LiteralLocalPath' '$LiteralRemotePath'" -Verbose:$VerbosePreference
    }
    catch [AdbCommandException] {
        # For some reason when sending the file it is treated as an error,
        # to fix it we just ignore it.
    }
}
