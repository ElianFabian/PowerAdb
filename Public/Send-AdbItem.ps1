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
        $sanitizedLiteralLocalPath = ConvertTo-ValidAdbStringArgument $LiteralLocalPath
        $sanitizedLiteralRemotePath = ConvertTo-ValidAdbStringArgument $LiteralRemotePath
        Invoke-AdbExpression -DeviceId $DeviceId -Command "push $sanitizedLiteralLocalPath $sanitizedLiteralRemotePath" -Verbose:$VerbosePreference
    }
    catch [AdbCommandException] {
        # For some reason when sending the file it is treated as an error,
        # to fix it we just ignore it.
    }
}
