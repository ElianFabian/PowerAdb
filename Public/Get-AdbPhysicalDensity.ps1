function Get-AdbPhysicalDensity {

    [CmdletBinding()]
    [OutputType([uint32[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    begin {
        # Length of 'Physical density: '
        $physicalDensityStrLength = 18
    }

    process {
        $DeviceId | Invoke-AdbExpression -Command "shell wm density" `
        | ForEach-Object {
            [uint32] $_.Substring($physicalDensityStrLength)
        }
    }
}
