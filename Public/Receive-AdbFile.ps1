function Receive-AdbFile {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $LiteralRemotePath,

        [Parameter(Mandatory)]
        [string] $LiteralLocalPath
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "pull '$LiteralRemotePath' '$LiteralLocalPath'" -Verbose:$VerbosePreference
        }
    }
}
