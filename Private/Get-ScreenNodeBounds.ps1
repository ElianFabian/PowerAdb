function Get-ScreenNodeBounds {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Xml.XmlNode] $Node
    )

    $bounds = $Node.bounds
    if ($bounds -notmatch '\[\d+,\d+\]\[\d+,\d+\]') {
        Write-Error "Bounds of node must be in the format '[x1,y1][x2,y2]', but was '$bounds'"
        return
    }

    $x1 = [float] $bounds.Substring(1, $bounds.IndexOf(',') - 1)
    $y1 = [float] $bounds.Substring($bounds.IndexOf(',') + 1, $bounds.IndexOf(']') - $bounds.IndexOf(',') - 1)
    $x2 = [float] $bounds.Substring($bounds.LastIndexOf('[') + 1, $bounds.LastIndexOf(',') - $bounds.LastIndexOf('[') - 1)
    $y2 = [float] $bounds.Substring($bounds.LastIndexOf(',') + 1, $bounds.LastIndexOf(']') - $bounds.LastIndexOf(',') - 1)

    $output = [PSCustomObject] @{
        X1 = $x1
        Y1 = $y1
        X2 = $x2
        Y2 = $y2
    }

    $output | Add-Member -MemberType NoteProperty -Name 'CenterX' -Value ([math]::Round(($x1 + $x2) / 2))
    $output | Add-Member -MemberType NoteProperty -Name 'CenterY' -Value ([math]::Round(($y1 + $y2) / 2))

    return $output
}
