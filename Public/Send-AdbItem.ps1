function Send-AdbItem {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $LiteralLocalPath,

        [Parameter(Mandatory)]
        [string] $LiteralRemotePath
    )

    try {
        # Sanitizing does not work for these arguments.
        Invoke-AdbExpression -SerialNumber $SerialNumber -Command "push '$LiteralLocalPath' '$LiteralRemotePath'" -Verbose:$VerbosePreference
    }
    catch [AdbCommandException] {
        if ($_.Exception.Message.StartsWith('adb: error:')) {
            throw $_
        }
        # For some reason when sending the file it is treated as an error,
        # to fix it we just ignore it.
    }
}
