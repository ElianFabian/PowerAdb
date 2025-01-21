function Send-AdbItem {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $LiteralLocalPath,

        [Parameter(Mandatory)]
        [string] $LiteralRemotePath
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "push '""$LiteralLocalPath""' '""$LiteralRemotePath""'" -Verbose:$VerbosePreference
        }
    }
}
