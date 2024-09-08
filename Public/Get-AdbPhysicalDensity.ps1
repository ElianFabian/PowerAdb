function Get-AdbPhysicalDensity {

    [CmdletBinding()]
    [OutputType([uint[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            return (Invoke-AdbExpression -DeviceId $id -Command "shell wm density") -as [uint]
        }
    }
}
