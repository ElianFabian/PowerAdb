function Get-AdbScreenSize {

    [CmdletBinding()]
    [OutputType([PSCustomObject], [string])]
    param (
        [string] $DeviceId,

        [switch] $AsString
    )

    Assert-ApiLevel -DeviceId $DeviceId -GreaterThanOrEqualTo 18

    $rawResult = Invoke-AdbExpression -DeviceId $DeviceId -Command "shell wm size" -Verbose:$VerbosePreference `
    | Out-String -Stream

    $rawPhysicalSize = $rawResult | Select-Object -First 1
    $physicalSize = $rawPhysicalSize.Replace('Physical size: ', '').Trim("`n")

    if ($rawResult.Count -gt 1) {
        $rawOverrideSize = $rawResult | Select-Object -Last 1
        $overrideSize = $rawOverrideSize.Replace('Override size: ', '').Trim("`n")
    }

    if ($AsString) {
        return [PSCustomObject]@{
            PhysicalSize = $physicalSize
            OverrideSize = $overrideSize
            Size         = if ($overrideSize) { $overrideSize } else { $physicalSize }
        }
    }

    $physicalResolution = $physicalSize.Split("x")

    $output = [PSCustomObject] @{
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

    return $output
}
