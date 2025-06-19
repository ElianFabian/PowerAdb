function Set-AdbContent {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string] $SerialNumber,

        [Parameter(Mandatory)]
        [string] $RemotePath,

        [AllowEmptyString()]
        [Parameter(Mandatory)]
        [string] $Value,

        [string] $RunAs,

        [switch] $NoNewline
    )

    if ($RunAs) {
        $runAsCommand = " run-as '$RunAs'"
    }
    if ($NoNewline) {
        $noNewLineArg = " -n"
    }

    # In this case the way chacters are escaped is different from the other functions
    # that use ConvertTo-ValidAdbStringArgument. I'm not sure why this is the case.
    # In other functions for example for a newline character we use `n, but in this case
    # we use \n.
    $sanitizedValue = ConvertTo-ValidAdbStringArgument $Value
    $sanitizedRemotePath = ConvertTo-ValidAdbStringArgument $RemotePath

    Invoke-AdbExpression -SerialNumber $SerialNumber -Command "shell$runAsCommand echo$noNewLineArg $sanitizedValue ``>`` $sanitizedRemotePath" -Verbose:$VerbosePreference
}
