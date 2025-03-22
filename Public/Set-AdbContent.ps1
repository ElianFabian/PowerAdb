function Set-AdbContent {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $RemotePath,

        [AllowEmptyString()]
        [Parameter(Mandatory)]
        [string] $Value,

        [string] $RunAs
    )

    begin {
        if ($RunAs) {
           $runAsCommand = " run-as '$RunAs'"
        }

        # In this case the way chacters are escaped is different from the other functions
        # that use ConvertTo-ValidAdbStringArgument. I'm not sure why this is the case.
        # In other functions for example for a newline character we use `n, but in this case
        # we use \n.
        $sanitizedValue = ConvertTo-ValidAdbStringArgument $Value
        $sanitizedRemotePath = ConvertTo-ValidAdbStringArgument $RemotePath
    }

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell$runAsCommand echo $sanitizedValue ``>`` $sanitizedRemotePath" -Verbose:$VerbosePreference
        }
    }
}
