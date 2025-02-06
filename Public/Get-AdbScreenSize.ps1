function Get-AdbScreenSize {

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
                Write-ApiLevelError -DeviceId $id -ApiLevelLessThan 18
                continue
            }

            $rawResult = Invoke-AdbExpression -DeviceId $id -Command "shell wm size" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
            | Out-String -Stream

            $rawPhysicalSize = $rawResult | Select-Object -First 1
            $physicalSize = $rawPhysicalSize.Replace('Physical size: ', '').Trim("`n")

            if ($rawResult.Count -gt 1) {
                $rawOverrideSize = $rawResult | Select-Object -Last 1
                $overrideSize = $rawOverrideSize.Replace('Override size: ', '').Trim("`n")
            }

            if ($AsString) {
                [PSCustomObject]@{
                    DeviceId     = $id
                    PhysicalSize = $physicalSize
                    OverrideSize = $overrideSize
                    Size         = if ($overrideSize) { $overrideSize } else { $physicalSize }
                }
                continue
            }

            $physicalResolution = $physicalSize.Split("x")

            $output = [PSCustomObject] @{
                DeviceId       = $id
                PhysicalWidth  = [uint32] $physicalResolution[0]
                PhysicalHeight = [uint32] $physicalResolution[1]
            }

            if ($overrideSize) {
                $overrideResolution = $overrideSize.Split("x")
                $output | Add-Member -MemberType NoteProperty -Name OverrideWidth -Value ([uint32] $overrideResolution[0])
                $output | Add-Member -MemberType NoteProperty -Name OverrideHeight -Value ([uint32] $overrideResolution[1])
            }

            $output | Add-Member -MemberType ScriptProperty -Name Width -Value {
                if ($this.OverrideWidth) {
                    return $this.OverrideWidth
                }
                return $this.PhysicalWidth
            }
            $output | Add-Member -MemberType ScriptProperty -Name Height -Value {
                if ($this.OverrideHeight) {
                    return $this.OverrideHeight
                }
                return $this.PhysicalHeight
            }

            $output
        }
    }
}
