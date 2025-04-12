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
            $sanitizedLiteralRemotePath = ConvertTo-ValidAdbStringArgument $LiteralRemotePath
            $sanitizedLiteralLocalPath = ConvertTo-ValidAdbStringArgument $LiteralLocalPath
            Invoke-AdbExpression -DeviceId $DeviceId -Command "pull $sanitizedLiteralRemotePath $sanitizedLiteralLocalPath" -Verbose:$VerbosePreference
        }
        catch [AdbCommandException] {
            # For some reason when receiving the file it is treated as an error,
            # to fix it we just ignore it.
        }
    }
    elseif (Test-Path -Path $localPath) {
        Write-Error "The file '$localPath' already exists." -Category ResourceExists -ErrorAction Stop
    }
}
