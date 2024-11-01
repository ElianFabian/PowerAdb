function Get-AdbContent {

    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $DeviceId,

        [Parameter(Mandatory)]
        [string] $RemotePath,

        [switch] $Raw,

        # This forces the path to be treated as a literal path
        [string] $RunAs
    )

    begin {
        if ($RunAs) {
           $runCommand = " run-as '$RunAs'"
        }
    }

    process {
        foreach ($id in $DeviceId) {
            Invoke-AdbExpression -DeviceId $id -Command "shell$runCommand cat '$RemotePath'" -Verbose:$VerbosePreference | Out-String -Stream:(-not $Raw)
        }
    }
}
