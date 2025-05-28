function Get-AdbScreenSize {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([PSCustomObject], [string])]
    param (
        [string] $DeviceId,

        [Parameter(ParameterSetName = 'AsString')]
        [switch] $AsString,

         [Parameter(ParameterSetName = 'SizeInDp')]
        [switch] $SizeInDp
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

    $scaleFactor = 1

    if ($SizeInDp) {
        $density = Get-AdbScreenDensity -DeviceId $DeviceId | Select-Object -ExpandProperty Density
        $scaleFactor = 160 / $density
    }

    $output = [PSCustomObject] @{
        PhysicalWidth  = [uint32] $physicalResolution[0] * $scaleFactor
        PhysicalHeight = [uint32] $physicalResolution[1] * $scaleFactor
    }

    if ($overrideSize) {
        $overrideResolution = $overrideSize.Split("x")
        $output | Add-Member -MemberType NoteProperty -Name OverrideWidth -Value ([uint32] $overrideResolution[0] * $scaleFactor)
        $output | Add-Member -MemberType NoteProperty -Name OverrideHeight -Value ([uint32] $overrideResolution[1 * $scaleFactor])
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
