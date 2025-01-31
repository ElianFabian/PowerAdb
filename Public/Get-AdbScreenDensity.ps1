function Get-AdbScreenDensity {

    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        # This is the value that appears in developer settings.
        # Using this parameter makes the function call slower.
        [switch] $IncludeWidthInDp
    )

    process {
        foreach ($id in $DeviceId) {
            $apiLevel = Get-AdbApiLevel -DeviceId $id -Verbose:$false
            if ($apiLevel -lt 18) {
                Write-Error "Screen density is not supported for device with id '$id' with API level of '$apiLevel'. Only API levels 18 and above are supported."
                continue
            }

            $rawResult = Invoke-AdbExpression -DeviceId $id -Command "shell wm density" -Verbose:$VerbosePreference -WhatIf:$false -Confirm:$false `
            | Out-String -Stream

            $rawPhysicalDensity = $rawResult | Select-Object -First 1
            $physicalDensity = [uint32] ($rawPhysicalDensity.Replace('Physical density: ', '').Trim("`n"))

            if ($rawResult.Count -gt 1) {
                $rawOverrideDensity = $rawResult | Select-Object -Last 1
                $overrideDensity = [uint32] ($rawOverrideDensity.Replace('Override density: ', '').Trim("`n"))
            }

            $output = [PSCustomObject] @{
                DeviceId        = $id
                PhysicalDensity = $physicalDensity
            }

            if ($overrideDensity) {
                $output | Add-Member -MemberType NoteProperty -Name OverrideDensity -Value $overrideDensity
            }

            $output | Add-Member -MemberType ScriptProperty -Name Density -Value {
                if ($this.OverrideDensity) {
                    return $this.OverrideDensity
                }
                return $this.PhysicalDensity
            }

            if ($IncludeWidthInDp) {
                $screenSize = Get-AdbScreenSize -DeviceId $id
                $output | Add-Member -MemberType NoteProperty -Name PhysicalWidthInDp -Value ($screenSize.Width / ($physicalDensity / 160))

                if ($overrideDensity) {
                    $output | Add-Member -MemberType NoteProperty -Name OverrideWidthInDp -Value ($screenSize.Width / ($overrideDensity / 160))
                }

                $output | Add-Member -MemberType ScriptProperty -Name WidthInDp -Value {
                    if ($this.OverrideWidthInDp) {
                        return $this.OverrideWidthInDp
                    }
                    return $this.PhysicalWidthInDp
                }
            }

            $output
        }
    }
}
