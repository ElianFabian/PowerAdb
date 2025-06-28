function Get-AdbBarFrame {

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param (
        [string] $SerialNumber
    )

    $rawData = Get-AdbServiceDump -SerialNumber $SerialNumber -Name 'window' -ArgumentList 'd' -Verbose:$VerbosePreference
    if (-not ($rawData | Select-String -Pattern $script:NavigationBarFramePattern)) {
        $rawData = Get-AdbServiceDump -SerialNumber $SerialNumber -Name 'window' -ArgumentList 'w' -Verbose:$VerbosePreference
    }

    $rawData | Select-String -Pattern $script:StatusBarFramePattern `
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

    $rawData | Select-String -Pattern $script:NavigationBarFramePattern `
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
        StatusBarFrame     = $statusBarFrame
        NavigationBarFrame = $navigatonBarFrame
    }
}



$script:StatusBarFramePattern = "m?(type=TYPE_TOP_GESTURES|type=ITYPE_STATUS_BAR|type=statusBars),? m?frame=\[(?<Left>\d+),(?<Top>\d+)\]\[(?<Right>\d+),(?<Bottom>\d+)\]"
$script:NavigationBarFramePattern = "m?(type=TYPE_BOTTOM_GESTURES|type=ITYPE_NAVIGATION_BAR|type=navigationBars),? m?frame=\[(?<Left>\d+),(?<Top>\d+)\]\[(?<Right>\d+),(?<Bottom>\d+)\]"



# TODO: We could do something like this to add autocompletion to PSCustomObject members.
# $FilePathComponents = @'
# [System.ComponentModel.EditorBrowsable(System.ComponentModel.EditorBrowsableState.Never)]
# public class ____________________________FilePathComponents
# {
#     public string ContainingFolder { get;set; }
#     public string FileBaseName { get;set; }
#     public string FileFullName { get;set; }
#     public string FileExtension { get;set; }
#     public string FullPathNoExtension { get;set; }
#     public string CompletePath { get;set; }
#     public string ParentFolder { get;set; }
#     public string UwU { get; }
# }
# '@

# Add-Type -TypeDefinition $FilePathComponents -Language CSharp

# function Get-FilePathComponents {

#     [OutputType('____________________________FilePathComponents')]

#     [CmdletBinding()]
#     param (
#         [Parameter(Mandatory,Position=0,ValueFromPipeline)]
#         [String[]]
#         $Path
#     )

#     begin {}

#     process {
#         foreach ($P in $Path) {
#             $obj = [FilePathComponents]::new()
#             $obj.ContainingFolder     = Split-Path $P -Parent
#             $obj.FileBaseName         = Split-Path $P -LeafBase
#             $obj.FileFullName         = Split-Path $P -Leaf
#             $obj.FileExtension        = Split-Path $P -Extension
#             $obj.FullPathNoExtension  = [IO.Path]::Combine((Split-Path $P -Parent),(Split-Path $P -LeafBase))
#             $obj.CompletePath         = $P
#             $obj.ParentFolder         = Split-Path (Split-Path $P -Parent) -Parent
#             $obj
#         }
#     }
# }
