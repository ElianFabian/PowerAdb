function New-AdbKeyGenFile {

    [OutputType([System.IO.FileInfo[]])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $Destination
    )

    $resolvedPath = Resolve-Path -Path $Destination
    if ($PSCmdlet.ShouldProcess("adb keygen ""$resolvedPath""", '', 'New-AdbKeyGenFile')) {
        Invoke-AdbExpression -Command "adb keygen ""$resolvedPath""" -IgnoreExecutionCheck -Verbose:$VerbosePreference

        Get-Item -LiteralPath $resolvedPath
        Get-Item -LiteralPath "$resolvedPath.pub"
    }
}
