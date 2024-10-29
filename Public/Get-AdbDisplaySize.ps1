function Get-AdbDisplaySize {

    [CmdletBinding()]
    [OutputType([PSCustomObject[]], [string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [switch] $AsString
    )

    process {
        $apiLevel = Get-AdbApiLevel -DeviceId $DeviceId -Verbose:$false
        foreach ($id in $DeviceId) {
            if ($apiLevel -lt 18) {
                Write-Error "Physical density is not supported for device with id '$id' with API level of '$apiLevel'. Only API levels 18 and above are supported."
                continue
            }

            $result = [string] (Invoke-AdbExpression -DeviceId $id -Command "shell wm size" -Verbose:$VerbosePreference)

            $resolutionStr = $result.Replace('Physical size: ', '').Trim("`n")

            if ($AsString) {
                $resolutionStr
                continue
            }

            $resolution = $resolutionStr.Split("x")

            [PSCustomObject] @{
                DeviceId = $id
                Width = [uint32] $resolution[0]
                Height = [uint32] $resolution[1]
            }
        }
    }
}
