function Add-AdbContent {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $RemotePath,

        [Parameter(Mandatory)]
        [string] $Content,

        [string] $RunAs
    )

    begin {
        if ($RunAs) {
            $runAsCommand = " run-as '$RunAs'"
        }
    }

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell$runAsCommand echo '$Content' >> '$RemotePath'" -Verbose:$VerbosePreference
        }
    }
}
