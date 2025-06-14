function New-AdbKeyGenFile {

    [OutputType([System.IO.FileInfo[]])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $Destination
    )

    if ($PSCmdlet.ShouldProcess("adb keygen ""$resolvedPath""", "", "New-AdbKeyGenFile")) {
        $resolvedPath = Resolve-Path -Path $Destination
        adb keygen "$resolvedPath"

        Get-Item -LiteralPath $resolvedPath
        Get-Item -LiteralPath "$resolvedPath.pub"
    }
}
