function Receive-AdbItem {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $LiteralRemotePath,

        [Parameter(Mandatory)]
        [string] $LiteralLocalPath,

        [switch] $Force
    )

    $itemName = Split-Path -Path $LiteralRemotePath -Leaf
    $localPath = Join-Path -Path $LiteralLocalPath -ChildPath $itemName

    if ($Force -or -not (Test-Path -Path $localPath)) {
        try {
            Assert-ValidAdbStringArgument $LiteralRemotePath -ArgumentName 'LiteralRemotePath'
            Assert-ValidAdbStringArgument $LiteralLocalPath -ArgumentName 'LiteralLocalPath'

            # Sanitizing does not work for these arguments.
            Invoke-AdbExpression -DeviceId $DeviceId -Command "pull '$LiteralRemotePath' '$LiteralLocalPath'" -Verbose:$VerbosePreference
        }
        catch [AdbCommandException] {
            if ($_.Exception.Message.StartsWith('adb: error:')) {
                throw $_
            }
            # For some reason when receiving the file it is treated as an error,
            # to fix it we just ignore it.
        }
    }
    elseif (Test-Path -Path $localPath) {
        Write-Error "The file '$localPath' already exists." -Category ResourceExists -ErrorAction Stop
    }
}
