function Add-AdbContent {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $RemotePath,

        [Parameter(Mandatory)]
        [string] $Content,

        [string] $RunAs,

        [switch] $NoNewline
    )

    if ($RunAs) {
        $runAsCommand = " run-as '$RunAs'"
    }
    if ($NoNewline) {
        $noNewLineArg = " -n"
    }

    $sanitizedContent = ConvertTo-ValidAdbStringArgument $Content

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell$runAsCommand echo$noNewLineArg $sanitizedContent ``>>`` '$RemotePath'" -Verbose:$VerbosePreference
}
