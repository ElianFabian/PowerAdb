function Get-AdbBarFrame {

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
                $statusBarFrame = [PSCustomObject] @{
                    Left   = [int] $_.Groups["Left"].Value
                    Top    = [int] $_.Groups["Top"].Value
                    Right  = [int] $_.Groups["Right"].Value
                    Bottom = [int] $_.Groups["Bottom"].Value
                }

                $statusBarFrame | Add-Member -MemberType ScriptProperty -Name Width -Value { $this.Right - $this.Left }
                $statusBarFrame | Add-Member -MemberType ScriptProperty -Name Height -Value { $this.Bottom - $this.Top }
            }

            $rawData | Select-String -Pattern $script:StatusBarFramePattern `
            | Select-Object -ExpandProperty Matches -First 1 `
            | ForEach-Object {
                $navigatonBarFrame = [PSCustomObject] @{
                    Left   = [int] $_.Groups["Left"].Value
                    Top    = [int] $_.Groups["Top"].Value
                    Right  = [int] $_.Groups["Right"].Value
                    Bottom = [int] $_.Groups["Bottom"].Value
                }

                $navigatonBarFrame | Add-Member -MemberType ScriptProperty -Name Width -Value { $this.Right - $this.Left }
                $navigatonBarFrame | Add-Member -MemberType ScriptProperty -Name Height -Value { $this.Bottom - $this.Top }
            }

            [PSCustomObject]@{
                DeviceId           = $id
                StatusBarFrame     = $statusBarFrame
                NavigationBarFrame = $navigatonBarFrame
            }
        }
    }
}



$script:StatusBarFramePattern = "m?(type=TYPE_TOP_GESTURES|type=ITYPE_STATUS_BAR|type=statusBars),? m?frame=\[(?<Left>\d+),(?<Top>\d+)\]\[(?<Right>\d+),(?<Bottom>\d+)\]"
$script:NavigationBarFramePattern = "m?(type=TYPE_BOTTOM_GESTURES|type=ITYPE_NAVIGATION_BAR|type=navigationBars),? m?frame=\[(?<Left>\d+),(?<Top>\d+)\]\[(?<Right>\d+),(?<Bottom>\d+)\]"
