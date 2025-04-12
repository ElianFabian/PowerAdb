function Get-AdbContent {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [string] $DeviceId,

        [Parameter(Mandatory)]
        [string] $RemotePath,

        [switch] $Raw,

        # This forces the path to be treated as a literal path
        [string] $RunAs
    )

    if ($RunAs) {
        $runCommand = " run-as '$RunAs'"
    }

    foreach ($path in $RemotePath) {
        $sanitizedRemotePath = ConvertTo-ValidAdbStringArgument $path

        Invoke-AdbExpression -DeviceId $DeviceId -Command "shell$runCommand cat $sanitizedRemotePath" -Verbose:$VerbosePreference | Out-String -Stream:(-not $Raw)
    }
}
