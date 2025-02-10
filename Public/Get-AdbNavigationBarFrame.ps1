function Get-AdbNavigationBarFrame {

    [OutputType([PSCustomObject[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell dumpsys window" -Verbose:$VerbosePreference `
            | Select-String -Pattern "(type=TYPE_BOTTOM_GESTURES|type=ITYPE_NAVIGATION_BAR|type=navigationBars) frame=\[(?<Left>\d+),(?<Top>\d+)\]\[(?<Right>\d+),(?<Bottom>\d+)\]" `
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
