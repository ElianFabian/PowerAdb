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
            if ($apiLevel -lt 18) {
                Write-Error "Physical density is not supported for device with id '$id' with API level of '$apiLevel'. Only API levels 18 and above are supported."
                continue
            }

            $result = [string] (Invoke-AdbExpression -DeviceId $id -Command "shell wm size" -Verbose:$VerbosePreference)

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
