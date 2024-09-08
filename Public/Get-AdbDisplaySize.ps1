function Get-AdbDisplaySize {

    [CmdletBinding()]
    [OutputType([uint[]], [string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [switch] $AsString
    )

    process {
        foreach ($id in $DeviceId) {
            $result = Invoke-AdbExpression -DeviceId $id -Command "shell wm size"

            $resolutionStr = $result.Split(": ")[1]

            if ($AsString) {
                return $resolutionStr
            }

            $resolution = $resolutionStr.Split("x")

            return @(
                [uint] $resolution[0],
                [uint] $resolution[1]
            )
        }
    }
}
