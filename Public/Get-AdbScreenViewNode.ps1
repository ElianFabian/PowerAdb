function Get-AdbScreenViewNode {

    [CmdletBinding()]
    [OutputType([System.Xml.XmlLinkedNode[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId
    )

    return $DeviceId | Get-AdbScreenViewContent -Verbose:$VerbosePreference
    | Select-Xml -XPath "//node" | Select-Object -ExpandProperty Node
}
