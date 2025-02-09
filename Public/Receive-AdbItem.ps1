function Receive-AdbItem {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $LiteralRemotePath,

        [Parameter(Mandatory)]
        [string] $LiteralLocalPath,

        [switch] $Force
    )

    process {
        foreach ($id in $DeviceId) {
            $itemName = Split-Path -Path $LiteralRemotePath -Leaf
            $localPath = Join-Path -Path $LiteralLocalPath -ChildPath $itemName

            if ($Force -or -not (Test-Path -Path $localPath)) {
                Invoke-AdbExpression -DeviceId $id -Command "pull '$LiteralRemotePath' '$LiteralLocalPath'" -Verbose:$VerbosePreference
            }
            elseif (Test-Path -Path $localPath) {
                Write-Error "The file '$localPath' already exists." -Category ResourceExists
            }
        }
    }
}
