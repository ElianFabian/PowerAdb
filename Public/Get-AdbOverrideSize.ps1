function Get-AdbOverrideSize {

    [CmdletBinding()]
    [OutputType([PSCustomObject[]], [string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [switch] $AsString
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 18) {
                Write-Error "Override density is not supported for device with id '$id' with API level of '$apiLevel'. Only API levels 18 and above are supported."
                continue
            }

            $result = Invoke-AdbExpression -DeviceId $id -Command "shell wm size" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
            | Out-String -Stream `
            | Select-Object -Last 1

            if (-not $result.Contains("Override size:")) {
                continue
            }

            $resolutionStr = $result.Replace('Override size: ', '').Trim("`n")

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
