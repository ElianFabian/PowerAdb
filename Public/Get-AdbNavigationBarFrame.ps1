function Get-AdbNavigationBarFrame {

    [OutputType([PSCustomObject[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            $rawData = Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys window d" -Verbose:$VerbosePreference
            if (-not ($rawData | Select-String -Pattern $script:NavigationBarFramePattern)) {
                $rawData = Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys window w" -Verbose:$VerbosePreference
            }

            $rawData | Select-String -Pattern $script:NavigationBarFramePattern `
            | Select-Object -ExpandProperty Matches -First 1 `
            | ForEach-Object {
                $output = [PSCustomObject] @{
                    DeviceId = $id
                    Left     = [int] $_.Groups["Left"].Value
                    Top      = [int] $_.Groups["Top"].Value
                    Right    = [int] $_.Groups["Right"].Value
                    Bottom   = [int] $_.Groups["Bottom"].Value
                }

                $output | Add-Member -MemberType ScriptProperty -Name Width -Value { $this.Right - $this.Left }
                $output | Add-Member -MemberType ScriptProperty -Name Height -Value { $this.Bottom - $this.Top }

                $output
            }
        }
    }
}




$script:NavigationBarFramePattern = "m?(type=TYPE_BOTTOM_GESTURES|type=ITYPE_NAVIGATION_BAR|type=navigationBars),? m?frame=\[(?<Left>\d+),(?<Top>\d+)\]\[(?<Right>\d+),(?<Bottom>\d+)\]"
