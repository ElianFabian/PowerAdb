function Get-AdbDisplaySize {

    [CmdletBinding()]
    [OutputType([uint32[]], [string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [switch] $AsString
    )

    begin {
        # Length of 'Physical size: '
        $physicalSizeStrLength = 15
    }

    process {
        foreach ($id in $DeviceId) {
            $result = [string] (Invoke-AdbExpression -DeviceId $id -Command "shell wm size")

            $resolutionStr = $result.Substring($physicalSizeStrLength).Trim("`n")

            if ($AsString) {
                $resolutionStr
                continue
            }

            $resolution = $resolutionStr.Split("x")

            @([uint32] $resolution[0], [uint32] $resolution[1])
        }
    }
}
