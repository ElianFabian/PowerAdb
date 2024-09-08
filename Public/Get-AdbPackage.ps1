function Get-AdbPackage {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    begin {
        # Length of 'package:'
        $packagePrefixStrLength = 8
    }

    process {
        $DeviceId | Invoke-AdbExpression -Command "shell pm list packages"
        | ForEach-Object { $_.Substring($packagePrefixStrLength) }
    }
}
